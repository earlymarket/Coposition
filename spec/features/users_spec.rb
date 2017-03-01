require "rails_helper"

RSpec.feature "Users", type: :feature do
  let(:user) { FactoryGirl.create :user }

  scenario "User signs up" do
    given_I_fill_in_sign_up_details
    and_I_click_sign_up
    then_I_should_see_device_creation
  end

  scenario "User signs up with taken email" do
    given_I_fill_in_sign_up_details
    fill_in "user_email", with: user.email
    and_I_click_sign_up
    then_I_should_see_sign_up
  end

  scenario "User signs in, edits account and signs out" do
    given_I_fill_in_log_in_details
    and_I_click_log_in
    then_I_should_see_welcome_page
    when_I_visit_edit_page
    and_I_edit_my_username
    then_I_should_see_a_new_username
    when_I_log_out
    then_I_should_be_logged_out
  end


  def given_I_fill_in_sign_up_details
    visit "/users/sign_up"
    fill_in "user_email", with: 'example@email.com'
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: "example"
  end

  def given_I_fill_in_log_in_details
    visit "/users/sign_in"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
  end

  def and_I_click_log_in
    click_button "Log in"
  end

  def and_I_click_sign_up
    click_button "Sign up"
  end

  def then_I_should_see_device_creation
    expect(page).to have_text "Device Creation"
  end

  def then_I_should_see_welcome_page
    expect(page).to have_text "Hello #{user.username}"
  end

  def then_I_should_see_sign_up
    expect(page).to have_text "Sign up"
  end

  def when_I_visit_edit_page
    click_on "settings"
  end

  def and_I_edit_my_username
    fill_in "user_username", with: "changed"
    fill_in "user_current_password", with: user.password
    click_on "Update"
  end

  def then_I_should_see_a_new_username
    visit "users/#{user.id}/dashboard"
    expect(page).to have_text "Hello changed"
  end

  def when_I_log_out
    click_on "Log Out"
  end

  def then_I_should_be_logged_out
    expect(page).to have_text "User Log In"
  end
end