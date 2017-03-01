require "rails_helper"

RSpec.feature "Approvals", type: :feature do
  let(:user) { FactoryGirl.create :user }
  let(:friend) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }

  background do
    given_I_am_signed_in
  end

  scenario "User adds friend" do
    when_I_add_a_friend
    then_I_should_have_a_pending_friend_request
  end

  # JAVASCRIPT
  scenario "User adds developer then revokes" do
    when_I_add_a_developer
    then_I_should_have_an_approved_app
    # JAVASCRIPT
    # when_I_revoke_the_approval
    # then_I_should_have_no_approved_apps
  end

  def given_I_am_signed_in
    visit "/users/sign_in"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    click_button "Log in"
  end

  def when_I_add_a_friend
    visit "/users/#{user.id}/approvals/new?approvable_type=User"
    fill_in "approval_approvable", with: friend.email
    click_button "Add"
  end

  def when_I_add_a_developer
    visit "/users/#{user.id}/approvals/new?approvable_type=Developer"
    fill_in "approval_approvable", with: developer.company_name
    click_button "Add"
  end

  def then_I_should_have_a_pending_friend_request
    expect(page).to have_text "You have sent 1 friend request"
  end

  def then_I_should_have_an_approved_app
    expect(page).to have_text "#{developer.company_name} Approved since"
  end

  def when_I_revoke_the_approval
    click_on "Revoke Approval", match: :first
  end

  def then_I_should_have_no_approved_apps
    expect(page).not_to have_text "Approved since"
  end
end