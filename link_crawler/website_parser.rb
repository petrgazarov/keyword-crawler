require 'nokogiri'
require 'active_support'
require 'active_support/core_ext'

class WebsiteParser
  KEYWORDS = [
    'parenting',
    'children',
    'kids',
    'finance',
    'money'
  ]

  attr_reader :status, :keywords

  def self.parse(html:, url_address:)
    new(html: html, url_address: url_address)
  end

  def initialize(html:, url_address:)
    @html = html
    @url_address = url_address

    parse_html
  end

  private

  def parse_html
    parse_status
    parse_keywords
  end

  def parse_status
    @status = (html.code == 200 ? 'SUCCESS' : "FAIL (#{html.code})")
  end

  def parse_keywords
    keywords_regex = KEYWORDS.map { |word| word + '([^(]|$)' }.join('|')

    if status == 'SUCCESS'
      @keywords = (relevant_html.scan(/(#{keywords_regex})/) + url_address.scan(/(#{keywords_regex})/))
        .uniq
        .join(', ')
    end
  end

  def relevant_html
    parsed_page = Nokogiri::HTML(html)

    body_and_title = parsed_page.at('body').try(:text).to_s + parsed_page.at('title').try(:text).to_s
    body_and_title = body_and_title.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    remove_script_and_style_tags!(body_and_title)

    body_and_title.downcase
  end

  def remove_script_and_style_tags!(html_body)
    script_tags = html_body.scan(/\<script.*\<\/script\>/)
    style_tags = html_body.scan(/\<style.*\<\/style\>/)

    (script_tags + style_tags).each { |tag| html_body.slice!(tag) }
  end

  attr_reader :html, :url_address
end
