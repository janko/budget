require "dry/initializer"

class ApplicationService
  extend Dry::Initializer

  def self.call(*args, **options, &)
    new(*args, **options).call(&)
  end
end
