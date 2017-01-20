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

def scrape_list(term, url)
  data = (scrape url => MembersPage).members.map do |row|
    row.to_h.merge(scrape(row.source => MemberPage).to_h)
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

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list(2012, 'http://parliament.gov.sy/arabic/index.php?node=210&RID=1')
scrape_list(2016, 'http://parliament.gov.sy/arabic/index.php?node=210&RID=26')
