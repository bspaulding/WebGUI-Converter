#! /usr/bin/ruby

require 'rubygems'
require 'json'
require 'webgui_scraper.rb'
require 'wxr_generator.rb'

def convert_site(hostname, article_urls)
  puts "----------------------------------------\nParsing WebGUI Site: #{hostname}\n----------------------------------------"
  webgui_scraper = WebGUIScraper.new(hostname, article_urls)
  articles = webgui_scraper.get_articles

  print "----------------------------------------\nGenerating Wordpress XML..."; STDOUT.flush
  xml = WXRGenerator.new(hostname, articles).to_xml
  print "Complete\n"; STDOUT.flush
  
  puts "Writing XML to File: northsuburbanchamber.com-articles-wordpress.xml\n----------------------------------------"
  
  require 'uri'
  file = File.open("#{URI.parse(hostname).host}-articles-wordpress.xml", 'w')
  file.write(xml)
  file.close
end

json_descriptor_file = File.open('northsuburban-webgui-descriptor.json')
descriptor = JSON.parse( json_descriptor_file.read )
descriptor = [descriptor] if descriptor.is_a? Hash

descriptor.each do |webgui_site|
  convert_site( webgui_site["hostname"], webgui_site["article_urls"] )
end  