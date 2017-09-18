module CountriesHelper
  def humanize_date_str(date_str)
    date = Date.parse(date_str)

    date.strftime("%b %-d")
  end
end
