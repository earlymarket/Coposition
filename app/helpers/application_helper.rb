module ApplicationHelper
  def fogged_icon(value)
    if value
      '<i class="material-icons">cloud_done</i>'.html_safe
    else
      '<i class="material-icons disabled-icon">cloud</i>'.html_safe
    end
  end

  def humanize_date(date)
    date.strftime("%A #{date.day.ordinalize} %B")
  end

  def humanize_date_and_time(date)
    date.strftime("%a #{date.day.ordinalize} %b %T")
  end

  def avatar_for(resource, options = {})
    options = options.reverse_merge(Rails.application.config_for(:cloudinary)['custom_transforms']['avatar'])
    resource.avatar? ? cl_image_tag(resource.avatar.public_id, options) : cl_image_tag('no_avatar', options)
  end

  def render_flash
    output = ''

    output << "Materialize.toast('#{j alert}', 3000, 'red');" if alert

    output << "Materialize.toast('#{j notice}', 3000);" if notice

    flash['errors'].each do |error|
      output << "Materialize.toast('#{j error}', 5000, 'red');"
    end if flash[:errors]

    flash.keys.each { |flash_type| flash.send('discard', flash_type) }
    output
  end

  def name_or_email_name(user)
    user.username.present? ? user.username : user.email.split('@').first
  end
end
