require "pagy"
require "pagy/extras/bootstrap"

module Helpers
  include Pagy::Frontend

  def nav_links
    {
      "Home" => root_path,
      "Expenses" => expenses_path,
      "Rules" => rules_path,
      "Categories" => categories_path,
    }
  end

  def date(date)
    date.strftime("%d.%m.%Y")
  end

  def price(value, currency: true)
    text = Money.from_amount(value).format
    text.sub!(/,\d{2}/, "") # remove cents
    text.sub!(" Kč", "") unless currency
    text
  end

  def icon(name)
    render "icons/#{name}"
  end

  def truncate(text, length: 60)
    if text.length >= length
      text[0...length] + "..."
    else
      text
    end
  end

  def dom_id(record)
    "#{Inflector.dasherize(Inflector.singularize(record.model.table_name))}-#{record.id}"
  end
end
