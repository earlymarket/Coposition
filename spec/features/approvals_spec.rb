require "rails_helper"

RSpec.feature "Approvals", type: :feature do
  let(:friend) { create :user }

  background do
    given_i_am_signed_in
  end

  scenario "User adds developer then revokes", js: true do
    given_a_developer_is_signed_up
    when_i_add_a_developer
    then_i_should_have_one_approved_app
    when_i_revoke_the_approval
    then_i_should_have_no_approved_apps
  end

  scenario "Developer requests approval from a user", js: true do
    given_a_developer_is_signed_up
    when_i_add_a_user
    then_i_should_see_request_sent
  end

  def given_i_am_signed_in
    visit "/users/sign_up"
    fill_in "user_email", with: "tommo@email.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: "tommo"
    click_on "Sign up"
  end

  def given_a_developer_is_signed_up
    visit "/developers/sign_up"
    fill_in "developer_email", with: "jimbo@email.com"
    fill_in "developer_password", with: "password"
    fill_in "developer_password_confirmation", with: "password"
    fill_in "developer_company_name", with: "fake company"
    fill_in "developer_redirect_url", with: "https://example.com"
    click_on "Sign up"
  end

  def when_i_add_a_friend
    click_on "Friends", match: :first
    click_on "add"
    fill_in "approval_approvable", with: friend.email
    click_button "Add"
  end

  def when_i_add_a_user
    click_on "New user"
    fill_in "approval_user", with: "tommo@email.com"
    click_button "Request"
  end

  def when_i_add_a_developer
    click_on "users", match: :first
    click_on "Apps", match: :first
    click_on "add"
    fill_in "approval_approvable", with: "fake company"
    find("#bottom-bar").click
    click_button "Add"
  end

  def then_i_should_have_one_approved_app
    expect(page).to have_text "Connected since", count: 1
  end

  def then_i_should_see_request_sent
    expect(page).to have_text "Successfully sent"
  end

  def when_i_revoke_the_approval
    click_on "Disconnect", match: :first
  end

  def then_i_should_have_no_approved_apps
    expect(page).not_to have_text "Connected since"
  end
end
