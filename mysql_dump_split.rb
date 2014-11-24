#!/usr/bin/env ruby

class MysqlDumpSplit
  def initialize file_path
    @file_path = file_path
    @table_name = 'head'
    @out_file = nil
  end
  
  def run
    File.open(@file_path, 'r') do |f|
      begin
        line = f.readline
        new_table! line if line.start_with?('-- Table structure for table')
        out_file.write line
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

MysqlDumpSplit.new(ARGV[0]).run

