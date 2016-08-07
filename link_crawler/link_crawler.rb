require 'csv'
require_relative './website_parser.rb'
require 'httparty'
require 'pry'

class LinkCrawler
  NUM_ATTEMPTS = 2
  RESULTS_FILE = 'link_crawler/results.csv'

  def initialize(source_file)
    @source_file = source_file
  end

  def visit_websites
    websites = File.readlines(source_file).uniq.map(&:chomp)

    websites.each do |url_address|
      begin
        visit_website(url_address)
      rescue Exception => e
        debug("#{url_address}: unhandled exception occured")

        next
      end
    end
  end

  private

  def visit_website(url_address)
    attempt = 1

    begin
      debug("#{url_address}: visiting #{attempt} time") if attempt == NUM_ATTEMPTS

      response = get_response(url_address)

      record_entry(url_address, response)

    rescue URI::InvalidURIError
      record_error(url_address, 'INVALID URL')

    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNRESET, OpenSSL::SSL::SSLError
      record_error(url_address, 'UNABLE TO LOAD WEBSITE')

    rescue Errno::ECONNREFUSED
      record_error(url_address, 'CONNECTION ERROR: is URL valid?')

    rescue Zlib::BufError, HTTParty::RedirectionTooDeep
      record_error(url_address, 'ERROR LOADING WEBSITE')

    rescue Exception => e
      if attempt == NUM_ATTEMPTS
        record_unhandled_error(url_address, e)
      else
        attempt += 1

        retry
      end
    end
  end

  def get_response(url_address)
    response = HTTParty.get(url_address, request_options)

    if response.code == 500
      unless url_address.include?('https')
        response = HTTParty.get(url_address.sub('http', 'https'), request_options)

        url_address.sub!('http', 'https') if response.code != 500
      end
    end

    response
  end

  def record_entry(url_address, response)
    parser = WebsiteParser.parse(html: response, url_address: url_address)

    CSV.open(RESULTS_FILE, "a+") do |csv|
      csv << [url_address, parser.status, parser.keywords]
    end
  end

  def record_error(url_address, status)
    CSV.open(RESULTS_FILE, "a+") do |csv|
      csv << [url_address, status]
    end
  end

  def record_unhandled_error(url_address, error)
    CSV.open(RESULTS_FILE, "a+") do |csv|
      csv << [url_address, 'UNHANDLED ERROR', nil, error, error.backtrace.inspect]
    end
  end

  def debug(message)
    puts message
  end

  def request_options
    { timeout: 45, verify: false }
  end

  attr_reader :source_file
end

puts "started at #{Time.now}"
LinkCrawler.new("#{Dir.pwd}/link_crawler/links.txt").visit_websites
puts "finished at #{Time.now}"
