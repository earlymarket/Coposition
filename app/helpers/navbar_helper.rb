module NavbarHelper
  def navbar_indicator(text, count)
    count > 0 ? text.html_safe + ' <div class="indicator"></div>'.html_safe : text
  end

  def navbar_dropdown(text, count)
    count > 0 ? text.html_safe + '<i class="dropdown-arrow material-icons right">arrow_drop_down</i>'.html_safe : text
  end
end
