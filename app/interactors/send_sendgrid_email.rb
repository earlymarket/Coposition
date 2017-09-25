class SendSendgridEmail
  include Interactor

  delegate :to, :subject, :id, :substitutions, :content, to: :context

  def call
    mail.from = SendGrid::Email.new(email: "support@coposition.com")
    mail.subject = subject
    mail.template_id = id
    mail.mail_settings = mail_settings
    add_substitutions
    add_content
    send_mail
  end

  private

  def send_mail
    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    response = sg.client.mail._("send").post(request_body: mail.to_json)
    context.fail! if response.status_code != "200"
    context.response = response
  end

  def add_substitutions
    personalization.add_to(SendGrid::Email.new(email: to))
    substitutions.each do |substitution|
      personalization.add_substitution(SendGrid::Substitution.new(key: substitution[:key], value: substitution[:value]))
    end
    mail.add_personalization(personalization)
  end

  def add_content
    return unless content && content.length
    mail.add_content(SendGrid::Content.new(type: "text/html", value: content))
  end

  def mail
    @mail ||= SendGrid::Mail.new
  end

  def personalization
    @personlization ||= SendGrid::Personalization.new
  end

  def mail_settings
    settings = SendGrid::MailSettings.new
    settings.sandbox_mode =  SendGrid::SandBoxMode.new(enable: Rails.env.test?)
    settings
  end
end
