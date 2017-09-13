class SendgridTemplate
  def initialize(to, subject, id)
    mail = SendGrid::Mail.new
    mail.from = SendGrid::Email.new(email: "coposition@support.com")
    mail.subject = subject
    mail.template_id = id
    personalization.add_to(SendGrid::Email.new(email: to))
  end

  def save
    mail.add_personalization(personalization)
  end

  def substitute(key, value)
    personalization.add_substitution(SendGrid::Substitution.new(key: key, value: value))
  end

  private

  def personlization
    @personlization ||= SendGrid::Personalization.new
  end
end
