require "rails_helper"

RSpec.feature "Developers", type: :feature do
  let(:developer) { create :developer }

  scenario "Developer signs up" do
    given_i_fill_in_sign_up_details
    and_i_click_sign_up
    then_i_should_see_developer_console
  end

  scenario "Developer signs up with taken email" do
    given_i_fill_in_sign_up_details
    fill_in "developer_email", with: developer.email
    fill_in "developer_email_confirmation", with: developer.email
    and_i_click_sign_up
    then_i_should_see_sign_up
  end

  scenario "Developer signs in, edits account then signs out" do
    given_i_fill_in_log_in_details
    and_i_click_log_in
    then_i_should_see_developer_console
    when_i_edit_company_name
    then_i_should_see_new_company_name
    when_i_sign_out
    then_i_should_not_be_signed_in
  end

  def given_i_fill_in_sign_up_details
    visit "/developers/sign_up"
    fill_in "developer_email", with: "jimbo@email.com"
    fill_in "developer_email_confirmation", with: "jimbo@email.com"
    fill_in "developer_password", with: "password"
    fill_in "developer_password_confirmation", with: "password"
    fill_in "developer_company_name", with: Faker::Internet.user_name(4..20, %w(_ -))
    fill_in "developer_redirect_url", with: "http://example.com"
  end

  def given_i_fill_in_log_in_details
    visit "/developers/sign_in"
    fill_in "developer_email", with: developer.email
    fill_in "developer_password", with: developer.password
  end

  def and_i_click_log_in
    click_button "Log in"
  end

  def and_i_click_sign_up
    click_button "Sign up"
  end

  def then_i_should_see_sign_up
    expect(page).to have_text("Sign up")
  end

  def then_i_should_see_developer_console
    expect(page).to have_text "Developer console"
  end

  def when_i_edit_company_name
    click_on "Edit your profile"
    fill_in "developer_company_name", with: "changed"
    click_button "Update"
  end

  def then_i_should_see_new_company_name
    expect(page).to have_text "changed"
  end

  def when_i_sign_out
    click_on "Sign out"
  end

  def then_i_should_not_be_signed_in
    expect(page).to have_text "Log In"
  end
end
