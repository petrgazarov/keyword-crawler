require_relative 'link_crawler'

puts "started at #{Time.now}"
LinkCrawler.new("#{Dir.pwd}/link_crawler/links.txt").visit_websites
puts "finished at #{Time.now}"
