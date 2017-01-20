# encoding: utf-8
# frozen_string_literal: true

require 'scraped'

class MemberRow < Scraped::HTML
  field :id do
    source.to_s[/nid=(\d+)/, 1]
  end

  field :name do
    tds[0].text.tidy
  end

  field :area do
    tds[1].text.tidy
  end

  field :category do
    tds[2].text.tidy
  end

  field :party do
    tds[3].text.tidy
  end

  field :deceased do
    tds[4].text.tidy
  end

  field :source do
    tds[5].css('a/@href').text
  end

  private

  def tds
    noko.css('td')
  end
end
