require 'rubygems'
require 'mechanize'

class WebGUIScraper
  attr_accessor :articles
  
  def initialize(aBaseURL, someRelativeArticleURLs)
    @base_url = aBaseURL
    @article_urls = someRelativeArticleURLs
    @articles = []
    @agent = Mechanize.new
  end
  
  def get_articles
    @articles = []
    @article_urls.each_with_index do |article_url, index|
      print "#{progress(index)}%\tParsing: #{URI.join(@base_url, article_url)}..."; STDOUT.flush
      article = {
        :title => get_article_title( article_url ),
        :html => get_article_html( article_url ) || "",
        :url => URI.join(@base_url, article_url),
        :relative_url => article_url,
        :attachments => get_article_attachment_urls( article_url )
      }
      @articles << article
      print "Complete (#{article[:attachments].count} attachments)\n"; STDOUT.flush
    end
    @articles
  end
  
  private
  def progress(index)
    result = ( (index + 1).to_f / @article_urls.count.to_f ) * 100.0
    (result * 10).round.to_f / 10
  end
  
  def get_article_title(aRelativeArticleURL)
    @agent.get( URI.join(@base_url, aRelativeArticleURL) ).search('div.wobjectArticle>h1').inner_html
  end

  def get_article_html(aRelativeArticleURL)
    html = @agent.get( URI.join(@base_url, aRelativeArticleURL) ).search('div.wobjectArticle').inner_html.split(/<h1>.*<\/h1>/)[1]
    unless html.nil?
      html.strip!
      html.gsub!(/(\n|[^0-9a-zA-Z\<\>\/ \.\,\"\'\!\@\#\$\%\^\&\*\(\)\:\;\+\=\-\_\?\<\>])/, '')
    end
    html
  end
  
  def get_article_attachment_urls(aRelativeArticleURL)
    attachment_urls = []
    images = @agent.get( URI.join(@base_url, aRelativeArticleURL) ).search('div.wobjectArticle img')
    images.each {|img| attachment_urls << URI.join(@base_url, img['src']) }
    attachment_urls
  end
end