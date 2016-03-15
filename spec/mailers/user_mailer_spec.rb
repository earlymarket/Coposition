require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe 'invite_email' do
    let(:mail) { UserMailer.invite_email('email@email.com') }

    it 'renders the subject' do
      expect(mail.subject).to match('invite')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql(['email@email.com'])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql([ApplicationMailer.default[:from]])
    end

    it 'renders sign up url' do
      expect(mail.body.encoded).to match('/users/sign_up')
    end
  end

  describe 'add_friend_email' do
    let(:user) { FactoryGirl::create :user }
    let(:friend) { FactoryGirl::create :user }
    let(:mail) { UserMailer.add_friend_email(user, friend) }

    it 'renders the subject' do
      expect(mail.subject).to match('friend request')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([friend.email])
    end

    it 'renders the senders email' do
      expect(mail.body.encoded).to match(user.email)
    end

    it 'renders friends page url' do
      url_string = "/users/#{friend.id}/friends"
      expect(mail.body.encoded).to match(url_string)
    end
  end
end
