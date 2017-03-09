require "rails_helper"

RSpec.feature "Permissions", js: true, type: :feature do
  background do
    given_i_am_signed_in
    and_they_log_out
    and_there_is_another_user
    and_they_have_added_me
    and_they_log_out
    and_i_sign_in
    and_i_have_a_device
    and_i_approve_the_friend_request
    and_i_am_on_the_devices_page
  end

  # scenario "User edits permissions", js: true do
  #   when_i_click_on_permissions
  #   then_i_should_see_my_friends_permissions
  #   when_i_check_bypass_fogging
  #   then_bypass_fogging_should_be_checked
  #   when_i_check_bypass_delay
  #   then_bypass_delay_should_be_checked
  #   when_i_choose_disable
  #   then_disabled_should_be_chosen
  # end

  def given_i_am_signed_in
    visit "/users/sign_up"
    fill_in "user_email", with: Faker::Internet.email
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: Faker::Internet.user_name(4..20, %w(_ -))
    click_on "Sign up"
  end

  def and_i_sign_in
    visit "/users/sign_in"
    fill_in "user_email", with: User.first.email
    fill_in "user_password", with: "password"
    click_on "Log in"
  end

  def and_i_have_a_device
    click_on "Devices", match: :first
    click_on "add"
    fill_in "device_name", with: "My device"
    click_button "Add"
  end

  def and_there_is_another_user
    visit "/users/sign_up"
    fill_in "user_email", with: Faker::Internet.email
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: Faker::Internet.user_name(4..20, %w(_ -))
    click_on "Sign up"
  end

  def and_they_log_out
    click_on "Log Out"
  end

  def and_they_have_added_me
    click_on "Friends", match: :first
    click_on "add"
    fill_in "approval_approvable", with: User.first.email
    click_button "Add"
    expect(page).to have_text "You have sent"
  end

  def and_i_approve_the_friend_request
    click_on "Friends", match: :first
    expect(page).to have_text "Pending Requests"
    click_on "Approve"
    expect(page).to have_text "Approved since"
  end

  def and_i_am_on_the_devices_page
    click_on "Devices", match: :first
    expect(page).to have_text "Your devices"
  end

  def when_i_click_on_permissions
    click_link "lock"
  end

  def then_i_should_see_my_friends_permissions
    expect(page).to have_text User.last.username
  end

  def when_i_check_bypass_fogging
    expect(page).to have_css("label##{Permission.last.id}_bypass-fogging")
    find("label##{Permission.last.id}_bypass-fogging", match: :first).click
  end

  def when_i_check_bypass_delay
    find("label##{Permission.last.id}_bypass-delay").click
  end

  def when_i_choose_disable
    find("label##{Permission.last.id}_disallowed").click
  end

  def then_bypass_fogging_should_be_checked
    expect("#{Permission.last.id}_bypass-fogging").to be_checked
  end

  def then_bypass_delay_should_be_checked
    expect("#{Permission.last.id}_bypass-delay").to be_checked
  end

  def then_disabled_should_be_chosen
    expect("#{Permission.last.id}_disallowed").to be_checked
  end
end