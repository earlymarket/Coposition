module NavbarHelper

  def navbar_indicator(text, count)
    count > 0 ? text.html_safe + ' <div class=""></div>'.html_safe : text
  end

end
