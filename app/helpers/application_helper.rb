module ApplicationHelper
  DEFAULT_TRANSFORMATION = "60x60cAvatar"

  def attribute_icon(value, icon)
    if value
      "<i class='material-icons enabled-icon'>#{icon}</i>".html_safe
    else
      "<i class='material-icons disabled-icon'>#{icon}</i>".html_safe
    end
  end

  def humanize_date(date)
    return unless date

    date.strftime("%A #{date.day.ordinalize} %B %Y")
  end

  def humanize_date_and_time(date)
    date.strftime("%a #{date.day.ordinalize} %b %T %Z")
  end

  def avatar_for(resource, options = {})
    options = options.reverse_merge(Rails.application.config_for(:cloudinary)["custom_transforms"]["avatar"])
    options = add_color_if_present(options, resource)
    resource.avatar? ? cl_image_tag(resource.avatar.public_id, options) : cl_image_tag("no_avatar", options)
  end

  def render_flash
    output = ""
    output << "Materialize.toast('#{j alert}', 3000, 'red');" if alert
    output << "Materialize.toast('#{j notice}', 3000);" if notice
    flash[:errors]&.each do |error|
      output << "Materialize.toast('#{j error}', 5000, 'red');"
    end
    flash.keys.each { |flash_type| flash.send("discard", flash_type) }
    output
  end

  private

  def add_color_if_present(options, resource)
    return options unless options["transformation"] && options["transformation"][0]

    if resource.respond_to?(:pin_color) && resource.pin_color
      options["transformation"][0] = options["transformation"][0] + resource.pin_color.to_s
    else
      options["transformation"][0] = DEFAULT_TRANSFORMATION
    end

    options
  end
end
