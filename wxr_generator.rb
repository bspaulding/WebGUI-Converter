require 'rubygems'
require 'builder'

class WXRGenerator
  def initialize(aHostname, somePages)
    @hostname = aHostname
    @pages = somePages
  end
  
  def to_xml
    xml = '<rss version="2.0" xmlns:excerpt="http://wordpress.org/export/1.0/excerpt/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:wfw="http://wellformedweb.org/CommentAPI/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:wp="http://wordpress.org/export/1.0/"><channel>'
    builder = Builder::XmlMarkup.new(:target => xml, :indent => 2)
    counter = 0
    builder.items do |builder|
      @pages.each_with_index do |article, index|
        builder.item do |builder|
          builder.title( article[:title].to_s )
          builder.tag!('content:encoded') {|builder| builder.cdata!( article[:html] ) }
          builder.tag!('wp:post_id', counter)
          builder.tag!('wp:post_type', 'page')
          builder.tag!('wp:comment_status', 'closed')
          builder.tag!('wp:status', 'publish')
          builder.tag!('wp:post_parent', '0')
          builder.tag!('wp:menu_order', index.to_s)
          builder.tag!('wp:postmeta') do |builder|
            builder.tag!('wp:meta_key', '_wp_old_slug')
            builder.tag!('wp:meta_value') {|builder| builder.cdata!( article[:relative_url] ) }
          end
        end

        article_id = counter

        article[:attachments].each do |attachment|
          builder.item do |builder|
            builder.title( attachment.to_s.split('/')[-1] )
            builder.tag!('wp:post_id', (counter += 1))
            builder.tag!('wp:post_parent', article_id)
            builder.tag!('wp:post_type', 'attachment')
            builder.tag!('wp:attachment_url', attachment)
            builder.tag!('wp:postmeta') do |builder|
              builder.tag!('wp:meta_key', '_wp_attached_file')
              builder.tag!('wp:meta_value') {|builder| builder.cdata!( attachment.to_s.gsub( @hostname, '' ) ) }
            end
          end      
        end

        counter += 1
      end
    end
    xml += '</channel></rss>'
  end
end
