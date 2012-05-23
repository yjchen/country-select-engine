require 'parse_helper'
require 'content_helper'
require 'hpricot'
require 'open-uri'

class CountrySelectEngine::Importer
  include CountrySelectEngine::ParseHelper
  include CountrySelectEngine::ContentHelper

  def locale
    @locale
  end

  def countries
    @countries
  end

  def import(locales)
    if locales.is_a?(String)
      locales = locales.split(' ')
    end
    locales.each do |locale|
      locale = locale.to_s
      @locale = locale
      # ----- Get the CLDR HTML ------
      begin
        puts "... getting the HTML file for locale '#{locale}'"
        doc = Hpricot( open("http://www.unicode.org/cldr/data/charts/summary/#{locale}.html") )
      rescue => e
        puts "[!] Invalid locale name '#{locale}'! Not found in CLDR (#{e})"
        exit 0
      end

      # ----- Parse the HTML with Hpricot ----
      puts "... parsing the HTML file"
      @countries = [] # reset countries list
      doc.search("//tr").each do |row|
        next if !country_row?(row)
        countries << { :code => get_code(row).to_sym, :name => get_name(row).to_s }
      end

      # ----- Write the parsed values into file -----
      puts "\n... writing the output"
      filename = File.join(Rails.root, 'config', 'locales', "countries.#{locale}.yml")
      puts filename
      filename += '.NEW' if File.exists?(filename) # Append 'NEW' if file exists
#      File.open(filename, 'w+') { |f| f << get_output }
      File.open(filename, 'w+') { |f| f << yaml_output }

      puts "\n---\nWritten values for the '#{locale}' into file: #{filename}\n"
    end
  end
end

=begin
  task :find_place_by_google, :begin, :end, :needs => :environment do |t, args|
    srand Time.now.to_i
    puts args
    (args.begin..args.end).each do |n|
=end

namespace :country_select do
  desc 'import locales'
  task :import_locales, [:locales] do |t, args|
    puts args
    CountrySelectEngine::Importer.new.import(args.locales)
  end
end
