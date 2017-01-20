#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'
require_rel 'lib'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
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
  data = (scrape url => MembersPage).member_rows.map do |row|
    row.merge scrape_person(row[:source])
      .merge(term: term)
  end
  data.map! do |row|
    h = {
      id:         row[:id],
      name:       row[:name],
      area:       row[:area],
      category:   row[:category],
      party:      row[:party],
      term:       row[:term],
      deceased:   row[:deceased],
      source:     row[:source],
      birth_date: row[:birth_date],
      email:      row[:email],
      image:      row[:image],
    }
    puts h
    h
  end
  ScraperWiki.save_sqlite(%i(id term), data)
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
