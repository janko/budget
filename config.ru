require_relative "config/boot"

use ReloadMiddleware if Settings.env == "development"

run -> (env) { Router.call(env) }
