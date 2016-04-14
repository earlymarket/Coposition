module ApplicationHelper

  def area_name(checkin)
    checkin.fogged_area || checkin.nearest_city.name
  end

  def fogged_icon(value)
    if value
      '<i class="material-icons">cloud_done</i>'.html_safe
    else
      '<i class="material-icons">cloud_off</i>'.html_safe
    end
  end

  def humanize_date(date)
    date.strftime("%a #{date.day.ordinalize} %b %T")
  end

  def avatar_for(resource, options = {})
    options = options.reverse_merge(avatar_defaults)
    resource.avatar? ? cl_image_tag(resource.avatar.public_id, options) : cl_image_tag('no_avatar', options)
  end

  def avatar_defaults
    {
      size: '60x60',
      crop: :thumb,
      gravity: 'face:center',
      radius: :max,
      class: 'avatar',
      format: 'png',
      default_image: 'placeholder.png'
    }
  end

  def render_flash
    output = ''

    if alert
      output << "Materialize.toast('#{j alert}', 3000, 'red');\n"
      flash.discard(:alert)
    end

    if notice
      output << "Materialize.toast('#{j notice}', 3000);\n"
      flash.discard(:notice)
    end

    if flash[:errors]
      flash['errors'].each do |error|
        output << "Materialize.toast('#{j error}', 5000, 'red');\n"
      end
      flash.discard(:errors)
    end

    output
  end

end
