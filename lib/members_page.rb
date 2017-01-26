# encoding: utf-8
# frozen_string_literal: true

require 'scraped'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.xpath('//table[@id="list"]//tr[td]').map do |tr|
      (fragment tr => MemberRow)
    end
  end
end
