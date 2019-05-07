module NavbarHelper
  def navbar_indicator(text, count)
    count.positive? ? (text + ' <div class="indicator"></div>').html_safe : text
  end
end
