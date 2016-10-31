require_relative 'keyword_crawler'

puts "started at #{Time.now}"
LinkCrawler.new("#{Dir.pwd}/websites.txt").visit_websites
puts "finished at #{Time.now}"
