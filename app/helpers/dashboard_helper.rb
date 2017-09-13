module DashboardHelper
  NO_FLAG = %w(AX AS AI AQ AW BM BV IO KY CX CC CK FK FO GF PF TF GI GL GP GU GG HM IM JE
            MO MQ YT MS AN NC NU NF MP PS PN PR RE BL SH MF PM GS SJ TK TC UM VG VI WF)

  def dashboard_country_name(code)
    iso_country(code) || code
  end

  def dashboard_flag(code)
    return image_tag("/flags/noflag.png") if no_flag?(code)
    return image_tag("/flags/#{code.downcase}.png") if iso_country(code)

    image_tag("/flags/noflag.png")
  end

  private

  def iso_country(code)
    ISO3166::Country.new(code).try(:name)
  end

  def no_flag?(code)
    NO_FLAG.any? { |flagless| flagless.casecmp(code.upcase).zero? }
  end
end
