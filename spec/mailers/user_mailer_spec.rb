require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'invite_email' do
    let(:email) { Faker::Internet.email }
    let(:mail) { UserMailer.invite_email(email) }

    it 'renders the subject' do
      expect(mail.subject).to match('invite')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql([ApplicationMailer.default[:from]])
    end

    it 'renders sign up url with email in url' do
      expect(mail.body.encoded).to include("users/sign_up?email=#{email}")
    end
  end

  describe 'add_user_email' do
    let(:user) { FactoryGirl.create :user }
    let(:added_user) { FactoryGirl.create :user }
    let(:developer) { FactoryGirl.create :developer }
    let(:friend_mail) { UserMailer.add_user_email(user, added_user, false) }
    let(:developer_mail) { UserMailer.add_user_email(developer, added_user, true) }

    it 'renders the subject' do
      expect(friend_mail.subject).to match('approval request')
    end

    it 'renders the receiver email' do
      expect(friend_mail.to).to eql([added_user.email])
    end

    it 'renders the senders email' do
      expect(friend_mail.body.encoded).to match(user.email)
      expect(developer_mail.body.encoded).to match(developer.company_name)
    end

    it 'renders the correct page url' do
      friends_url_string = "/users/#{added_user.id}/friends"
      apps_url_string = "/users/#{added_user.id}/apps"
      expect(friend_mail.body.encoded).to match(friends_url_string)
      expect(developer_mail.body.encoded).to match(apps_url_string)
    end
  end
end
