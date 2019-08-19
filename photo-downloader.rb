#!/usr/bin/env ruby

require 'csv'
require 'open-uri'
require 'optparse'

@total_photos = 0

def image_file_name(directory, asset_id, index, total_photos)
  prefix = "./#{directory}/Crystal_Lake_Asset_ID_#{asset_id}_Photo_#{@total_photos}.jpg"
end

def download_photos(directory, row)
  photo_columns = row.select { |k, _v| k.include?('Photo') }.to_h
  photo_columns.each do |name, value|
    photo_urls = value.to_s.split('; ')
    photo_urls.each_with_index do |photo_url, index|
      @total_photos += 1
      io = URI.parse(photo_url).open
      file_name = image_file_name(directory, row.first.last, index, @total_photos)
      File.rename(io.path, file_name)
    end
  end
end

options = {
  directory: nil,
  csv_file: nil
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: photo-downloader.rb [options]'
  opts.on('-f', '--file csv', 'CSV File to pull photos from') do |file|
    options[:csv_file] = file
  end

  opts.on('-d', '--directory directory', 'Directory to download photos to') do |directory|
    options[:directory] = directory
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

if $PROGRAM_NAME == __FILE__
  csv_file = options[:csv_file]
  directory = options[:directory]
  puts "Checking arguments...."
  if csv_file && File.zero?(csv_file) || csv_file.nil?
    puts 'Error: CSV is empty.'
  elsif directory.nil?
    puts 'Error: No directory present.'
  else
    puts "Reading CSV...."
    counter = 0
    file_data = File.read(csv_file)
    CSV.parse(file_data, headers: true, encoding: 'UTF-8').each do |row|
      download_photos(directory, row)
      counter += 1
      puts "Processed #{counter} assets..."
    end
    puts "Downloaded #{@total_photos} photos."
    puts "Done with photo download!"
  end
end
