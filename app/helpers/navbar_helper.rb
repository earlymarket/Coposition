module NavbarHelper

  def navbar_badge(text, count)
    count > 0 ? text.html_safe + "<span class=\"new badge\">#{count}</span>".html_safe : text
  end

end
