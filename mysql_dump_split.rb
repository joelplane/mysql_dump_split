#!/usr/bin/env ruby

class MysqlDumpSplit
  USAGE="mysql_dump_split.rb <mysql backup>.sql [<table to exclude> [...] ]"

  def initialize file_path, skip_tables = []
    @file_path = file_path
    @skip_tables = skip_tables
    @table_name = 'head'
    @out_file = nil
  end
  
  def run
    puts "Will skip table names '#{@skip_tables.join("', '")}'"

    File.open(@file_path, 'r') do |f|
      begin
        line = f.readline

        if line.start_with?('-- Table structure for table')
          puts "Skipped over #{@table_name}" if @skip_tables.include?(@table_name)
          new_table! line

          puts "Starting table #{@table_name}"
        end

        out_file.write line unless @skip_tables.include?(@table_name)
      end until f.eof?
    end
    close_out_file
  end
  
  def new_table! line
    @table_name = /`(.*)`/.match(line)[1]
    close_out_file
  end
  
  def close_out_file
    @out_file && @out_file.close
    @out_file = nil
  end
  
  def out_file
    @out_file ||= File.open(file_name_for_table, 'wb')
  end
  
  def file_name_for_table
    @file_path.sub('.sql', "-#{@table_name}.sql")
  end
end

backup = ARGV.shift
skip_tables = ARGV

MysqlDumpSplit.new(backup, skip_tables).run

