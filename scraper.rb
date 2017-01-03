#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def date_from(text)
  return if text.to_s.empty?
  Date.parse(text).to_s
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(term, url)
  puts url.to_s
  noko = noko_for(url)
  noko.xpath('//table[@id="list"]//tr[td]').each do |tr|
    tds = tr.css('td')
    link = tds[5].css('a/@href').text
    link = URI.join url, link unless link.to_s.empty?

    data = {
      id:       link.to_s[/nid=(\d+)/, 1],
      name:     tds[0].text.tidy,
      area:     tds[1].text.tidy,
      category: tds[2].text.tidy,
      party:    tds[3].text.tidy,
      term:     term,
      deceased: tds[4].text.tidy,
      source:   link.to_s,
    }.merge scrape_person(link)
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end

def scrape_person(url)
  noko = noko_for(url)

  # Members
  data = {
    birth_date: date_from(noko.xpath('//td/b[contains(.,"تاريخ الولادة")]/following-sibling::text()').text),
    email:      noko.xpath('//td/b[contains(.,"البريد الإلكتروني")]/following-sibling::text()[contains(.,"@")]').text.split(/ /).find { |e| e.include? '@' },
    image:      noko.css('.alginLeft img/@src').text,
  }
  data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
  data
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list(2012, 'http://parliament.gov.sy/arabic/index.php?node=210&RID=1')
scrape_list(2016, 'http://parliament.gov.sy/arabic/index.php?node=210&RID=26')
