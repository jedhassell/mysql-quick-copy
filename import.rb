require 'mysql2'
require 'byebug'
require 'fileutils'
require 'io/console'
require 'optparse'

class Import

  def initialize(source: '/tmp', database: 'real_store_development', user: 'root', password: '')
    @source = File.expand_path(source)
    @user = user
    @password = password
    @database = database
    @db_files = File.join(@source, @database)
    @mysql = Mysql2::Client.new(
      host: 'localhost',
      username: @user,
      password: @password
    )

    @mysql.query("drop database if exists #{@database}") ############### REMOVE ME
    @mysql.query("create database #{@database}")
    @mysql.query("use #{database}")
    @datadir = @mysql.query('select @@datadir;').first['@@datadir']

    import_schema

    @tables = @mysql.query('show tables').map { |item| item.values.first }

    @mysql.query('SET FOREIGN_KEY_CHECKS=0')

    spinner = ['—', '\\', '|', '/', '—', '\\', '|']

    num_tables = @tables.size
    @tables.each_with_index do |table, i|
      print " [#{i}/#{num_tables}] complete.  #{spinner[i % spinner.size]}\r"
      $stdout.flush
      drop_tablespace(table)
      copy_table_data(table)
      import_tablespace(table)
    end

    @mysql.query('SET FOREIGN_KEY_CHECKS=1')
  end

  def drop_tablespace(table)
    @mysql.query("ALTER TABLE #{table} DISCARD TABLESPACE")
  end

  def import_tablespace(table)
    @mysql.query("ALTER TABLE #{table} IMPORT TABLESPACE")
  end

  def import_schema
    `mysql -u #{@user} #{@database} < #{File.join(@db_files, 'schema.sql')}`
  end

  def copy_table_data(table)
    FileUtils.cp([File.join(@db_files, "#{table}.cfg"), File.join(@db_files, "#{table}.ibd")], File.join(@datadir, @database))
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-s", "--source SOURCE", "the source directory") do |source|
    options[:source] = source
  end

  opts.on("-d", "--database DATABASE", "The database name") do |database|
    options[:database] = database
  end

  opts.on("-u", "--user USER", "The user") do |user|
    options[:user] = user
  end

  opts.on("-p", "--password PASSWORD", "The password") do |e|
    options[:password] = e
  end
end.parse!

Import.new(options)
