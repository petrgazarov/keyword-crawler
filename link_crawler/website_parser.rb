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

  attr_accessor :status, :keywords

  def self.parse(html:, url_address:)
    new(html: html, url_address: url_address)
  end

  def initialize(html:, url_address:)
    @html = html
    @url_address = url_address
    @keywords = []

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
    if status == 'SUCCESS'
      KEYWORDS.each do |keyword|
        @keywords << relevant_html.scan(/(#{keyword}(?:[^(]|$))/).flatten.map { |match| match[0...-1] }.uniq.join
        @keywords << url_address.scan(/#{keyword}/).uniq.join
      end

      @keywords.reject!(&:blank?).uniq!
    end

    @keywords = keywords.join(', ')
  end

  def relevant_html
    parsed_page = Nokogiri::HTML(html)

    body = parsed_page.css('body').to_s
    body = body.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    remove_tag_attributes!(body)

    body.downcase
  end

  def remove_tag_attributes!(html_body)
    a_attributes = html_body.scan(/<a.*<\/a>/)
    tag_attributes = html_body.scan(/<[^>]*>/)

    (a_attributes + tag_attributes).each { |tag_attribute| html_body.slice!(tag_attribute) }
  end

  attr_reader :html, :url_address
end
