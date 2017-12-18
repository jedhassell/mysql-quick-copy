require 'mysql2'
require 'byebug'
require 'fileutils'
require 'optparse'

class Export
  def initialize(output: '/tmp', database: 'real_store_development', user: 'root', password: '')
    @output = File.expand_path(output)
    @user = user
    @password = password
    @database = database
    @destination = File.join(output, @database)
    @mysql = Mysql2::Client.new(
      host: 'localhost',
      username: @user,
      password: @password,
      database: @database
    )

    @datadir = @mysql.query('select @@datadir;').first['@@datadir']
    @tables = @mysql.query('show tables').map { |item| item.values.first }

    FileUtils.mkdir_p(@destination)
    dump_schema

    spinner = ['—', '\\', '|', '/', '—', '\\', '|']
    num_tables = @tables.size
    @tables.each_with_index do |table, i|
      print " [#{i}/#{num_tables}] complete.  #{spinner[i % spinner.size]}\r"
      $stdout.flush
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

  def dump_schema
    password = @password.empty? ? '' : "-p#{@password}"
    `mysqldump -u root #{password} --no-data #{@database} > #{File.join(@destination, 'schema.sql')}`
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-o", "--output OUTPUT", "the output directory") do |source|
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

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

Export.new(options)
