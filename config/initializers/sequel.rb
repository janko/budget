require "sequel"
require "forme"

DB = Sequel.connect(Settings.database_url)
DB.logger = Settings.logger
DB.extension :pg_json, :null_dataset

Sequel::Model.cache_associations = false if Settings.env == "development"

Sequel::Model.plugin :forme_set
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :boolean_readers
