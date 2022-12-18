require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir Settings.root.join("app")
loader.collapse Settings.root.join("app/*")
loader.enable_reloading if Settings.env == "development"
loader.setup
loader.eager_load if Settings.env == "production" || ENV["CI"]

if Settings.env == "development"
  require "listen"
  require "concurrent/atomic/read_write_lock"
  require "singleton"

  class Reloader
    include Singleton

    LISTEN_PATHS = [
      Settings.root.join("app"),
      Settings.root.join("db"),
    ]

    def initialize
      @lock = Concurrent::ReadWriteLock.new
      @listener = Listen.to(*LISTEN_PATHS) { reload }
      @listener.start
    end

    def wrap
      @lock.with_read_lock { yield }
    end

    def reload
      @lock.with_write_lock { loaders.each(&:reload) }
    end

    private

    def loaders
      Zeitwerk::Registry.loaders.select(&:reloading_enabled?)
    end
  end

  class ReloadMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Reloader.instance.wrap { @app.call(env) }
    end
  end
end
