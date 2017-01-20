# encoding: utf-8
# frozen_string_literal: true

require 'scraped'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :birth_date do
    date_from(noko.xpath('//td/b[contains(.,"تاريخ الولادة")]/following-sibling::text()')
                  .text)
  end

  field :email do
    noko.xpath('//td/b[contains(.,"البريد الإلكتروني")]/following-sibling::text()[contains(.,"@")]')
        .text
        .split(/ /)
        .find { |e| e.include? '@' }
  end

  field :image do
    noko.css('.alginLeft img/@src').text
  end

  private

  def date_from(text)
    return if text.to_s.empty?
    Date.parse(text).to_s
  end
end
