require 'mysql2'
require 'slop'
require 'byebug'
require 'fileutils'

class Import

  # get mysqls datadir
  # source db
  # username
  # password
  # destination

  def initialize
    # puts ARGV
    source_dir = '/usr/local/var/mysql_blank'
    @database = 'real_store_development6'
    # @destination = File.join(destination_datadir, @database)
    @mysql = Mysql2::Client.new(:host => 'localhost', :username => 'root', :database => @database)
    @datadir = @mysql.query('select @@datadir;').first['@@datadir']
    @tables = @mysql.query('show tables').map { |item| item.values.first }

    FileUtils.mkdir_p(@destination)

    @tables.each do |table|
      puts '.'
      flush_table(table)
      copy_table(table)
      unlock_tables
    end
  end

  def flush_table(table)
    @mysql.query("FLUSH TABLES #{table} FOR EXPORT")
  end

  def copy_table(table)
    ['cfg', 'ibd'].each do |ext|
      FileUtils.cp(File.join(@datadir, @database, "#{table}.#{ext}"), @destination)
    end
  end

  def unlock_tables
    @mysql.query('unlock tables')
  end

  # def parse_options
  #   # use slop
  # end
  #
  # def dump_schema
  #   `mysqldump -u root -p --no-data dbname > schema.sql`
  # end

end

Import.new
