module Helpers
  def nav_links
    {
      "Home" => root_path,
      "Expenses" => expenses_path,
      "Categories" => categories_path,
    }
  end

  def date(date)
    date.strftime("%d.%m.%Y")
  end

  def price(value)
    "#{"%.2f" % value} CZK"
  end

  def icon(name)
    render "icons/#{name}"
  end
end
