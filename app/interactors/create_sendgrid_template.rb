class CreateActivity
  include Interactor

  delegate :to, :subject, :id, :subsitutions, :content, to: :context

  def call
    mail.from = SendGrid::Email.new(email: "coposition@support.com")
    mail.subject = subject
    mail.template_id = id
    add_substitutions
    add_content
    context.template = mail
  end

  def add_substitutions
    personalization.add_to(SendGrid::Email.new(email: to))
    subsitutions.each do |subsitution|
      personalization.add_substitution(SendGrid::Substitution.new(key: subsitution.key, value: subsitution.value))
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
end
