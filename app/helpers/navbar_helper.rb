module NavbarHelper
  def navbar_indicator(text, count)
    count > 0 ? text.html_safe + ' <div class="indicator"></div>'.html_safe : text
  end
end
