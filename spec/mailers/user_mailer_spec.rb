# require "rails_helper"

# RSpec.describe UserMailer, type: :mailer do
#   describe "invite_email" do
#     let(:email) { Faker::Internet.email }
#     let(:mail) { UserMailer.invite_email(email) }

#     it "calls SendSendgridEmail interactor" do
#       allow(SendSendgridEmail).to receive :call
#       mail
#       expect(SendSendgridEmail).to have_received :call
#     end
#   end

#   #   it "renders the subject" do
#   #     expect(mail.subject).to match("invite")
#   #   end

#   #   it "renders the receiver email" do
#   #     expect(mail.to).to eql([email])
#   #   end

#   #   it "renders the sender email" do
#   #     expect(mail.from).to eql([ApplicationMailer.default[:from]])
#   #   end

#   #   it "renders sign up url with email in url" do
#   #     expect(mail.body.encoded).to include("users/sign_up?email=#{email}")
#   #   end
#   # end

#   describe "add_user_email" do
#     let(:user) { create :user }
#     let(:added_user) { create :user }
#     let(:developer) { create :developer }
#     let(:friend_mail) { UserMailer.add_user_email(user, added_user, false) }
#     let(:developer_mail) { UserMailer.add_user_email(developer, added_user, true) }
#     let(:friend_mail_body) { CGI.unescapeHTML(friend_mail.body.encoded) }
#     let(:developer_mail_body) { CGI.unescapeHTML(developer_mail.body.encoded) }

#     it "calls SendSendgridEmail interactor" do
#       allow(SendSendgridEmail).to receive :call
#       friend_mail
#       expect(SendSendgridEmail).to have_received :call
#     end

#     # it "renders the subject" do
#     #   expect(friend_mail.subject).to match("approval request")
#     # end

#     # it "renders the receiver email" do
#     #   expect(friend_mail.to).to eql([added_user.email])
#     # end

#     # it "renders the senders email" do
#     #   expect(friend_mail_body).to match(user.email)
#     #   expect(developer_mail_body).to match(developer.company_name)
#     # end

#     # it "renders the correct page url" do
#     #   friends_url_string = "/users/#{added_user.id}/friends"
#     #   apps_url_string = "/users/#{added_user.id}/apps"
#     #   expect(friend_mail_body).to match(friends_url_string)
#     #   expect(developer_mail_body).to match(apps_url_string)
#     # end
#   end

#   describe "no_activity_email" do
#     let(:user) { create :user }
#     let(:activity_mail) { UserMailer.no_activity_email(user) }

#     it "calls SendSendgridEmail interactor" do
#       allow(SendSendgridEmail).to receive :call
#       activity_mail
#       expect(SendSendgridEmail).to have_received :call
#     end

#     # it "renders the subject" do
#     #   expect(activity_mail.subject).to match("Coposition activity")
#     # end

#     # it "renders the receiver email" do
#     #   expect(activity_mail.to).to eql([user.email])
#     # end

#     # it "renders the correct page url" do
#     #   devices_url = "/users/#{user.id}/devices"
#     #   expect(activity_mail.body.encoded).to match(devices_url)
#     # end
#   end
# end
