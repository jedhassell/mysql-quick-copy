require 'mysql2'
require 'slop'
require 'byebug'
require 'fileutils'
require 'io/console'

class Import

  def initialize
    source_dir = '/usr/local/var/mysql_blank'
    @database = 'real_store_development6'
    @db_files = File.join(source_dir, @database)
    @mysql = Mysql2::Client.new(:host => 'localhost', :username => 'root')
    @mysql.query("drop database if exists #{@database}") ############### REMOVE ME
    @mysql.query("create database #{@database}")
    @mysql.query("use #{@database}")
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
    `mysql -u root #{@database} < #{File.join(@db_files, 'schema.sql')}`
  end

  def copy_table_data(table)
    FileUtils.cp([File.join(@db_files, "#{table}.cfg"), File.join(@db_files, "#{table}.ibd")], File.join(@datadir, @database))
  end

  # def parse_options
  #   # use slop
  # end
end

Import.new
