require "bundler/setup"
require_relative "config/settings"
require "sequel_tools"
require "sequel/core"

db = Sequel.connect(Settings.database_url, test: false, keep_reference: false)

namespace :db do
  SequelTools.inject_rake_tasks({
    dbadapter: db.opts[:adapter],
    dbname: db.opts[:database],
    dump_schema_on_migrate: Settings.env == "development",
    schema_location: "db/schema.sql",
    log_level: :info,
    sql_log_level: :info,
  }, self)
end

desc "Open a ruby console with the application loaded"
task :console => :boot do
  require "irb"
  ARGV.clear
  IRB.start
end

desc "Import new transactions into the database"
task :import => :boot do
  from = DB[:expenses].max(:date)
  to = Date.today

  ImportTransactions.call(from: from, to: to, fio_token: Settings.fio_token_business)
  ImportTransactions.call(from: from, to: to, fio_token: Settings.fio_token_shared)
end

task :backup do
  system "pg_dump", db.opts[:database], out: "tmp/backup-#{Date.today.strftime("%Y%m%d")}.sql"
end

task :restore do
  dump = Dir["tmp/backup-*.sql", sort: true].last
  system "dropdb", db.opts[:database]
  system "createdb", db.opts[:database]
  system "psql", db.opts[:database], in: dump
end

task :boot do
  require_relative "config/boot"
end
