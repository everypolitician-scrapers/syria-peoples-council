#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def date_from(text)
  return if text.to_s.empty?
  Date.parse(text).to_s
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  puts url.to_s
  noko = noko_for(url)
  noko.xpath('//table[@id="list"]//tr[td]').each do |tr|
    tds = tr.css('td')
    link = tds[5].css('a/@href').text
    link = URI.join url, link unless link.to_s.empty?

    data = { 
      id: link.to_s[/nid=(\d+)/, 1],
      name: tds[0].text.tidy,
      area: tds[1].text.tidy,
      category: tds[2].text.tidy,
      party: tds[3].text.tidy,
      term: 2012,
      deceased: tds[4].text.tidy,
      source: link.to_s,
    }.merge scrape_person(link)
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

def scrape_person(url)
  noko = noko_for(url)

# Members
  data = {
    birth_date: date_from(noko.xpath('//td/b[contains(.,"تاريخ الولادة")]/following-sibling::text()').text),
    email: noko.xpath('//td/b[contains(.,"البريد الإلكتروني")]/following-sibling::text()[contains(.,"@")]').text.split(/ /).find { |e| e.include? '@' },
    image: noko.css('.alginLeft img/@src').text,
  }
  data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
  data
end

(0..2).each { |i| scrape_list('http://parliament.gov.sy/arabic/index.php?node=210&First=0&Last=274&CurrentPage=%d' % i) }
