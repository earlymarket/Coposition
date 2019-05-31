require "rails_helper"

RSpec.feature "Permissions", type: :feature do
  scenario "User edits permissions", js: true do
    given_i_am_signed_in
    and_they_log_out
    and_there_is_another_user
    and_they_have_added_me
    and_they_log_out
    and_i_sign_in
    and_i_have_a_device
    and_i_approve_the_friend_request
    and_i_am_on_the_devices_page
    when_i_click_on_permissions
    then_i_should_see_my_friends_permissions
    when_i_check_bypass_fogging
    then_bypass_fogging_should_be_checked
    when_i_check_bypass_delay
    then_bypass_delay_should_be_checked
    when_i_choose_disable
    then_disabled_should_be_chosen
  end

  def given_i_am_signed_in
    visit "/users/sign_up"
    fill_in "user_email", with: "tommo@email.com"
    fill_in "user_email_confirmation", with: "tommo@email.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: "tommo"
    find(:css, "button.btn.waves-effect.waves-light").trigger("click")
  end

  def and_i_sign_in
    visit "/users/sign_in"
    fill_in "user_email", with: "tommo@email.com"
    fill_in "user_password", with: "password"
    click_on "Log in"
  end

  def and_i_have_a_device
    click_on "Devices", match: :first
    click_on "add"
    fill_in "device_name", with: "My_device"
    find("div.select-wrapper input").click
    find("div.select-wrapper li", text: "Laptop").click
    click_button "Add"
  end

  def and_there_is_another_user
    visit "/users/sign_up"
    fill_in "user_email", with: "jimbo@email.com"
    fill_in "user_email_confirmation", with: "jimbo@email.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: "jimbo"
    find(:css, "button.btn.waves-effect.waves-light").trigger("click")
  end

  def and_they_log_out
    click_on "Log Out", match: :first
  end

  def and_they_have_added_me
    click_on "Friends", match: :first
    click_on "add"
    fill_in "approval_approvable", with: "tommo@email.com"
    click_button "Add"
  end

  def and_i_approve_the_friend_request
    click_on "Friends", match: :first
    expect(page).to have_text "Pending Requests"
    click_on "Approve"
    expect(page).to have_text "Connected since"
  end

  def and_i_am_on_the_devices_page
    click_on "Devices", match: :first
    expect(page).to have_text "Your devices"
  end

  def when_i_click_on_permissions
    click_link "lock"
  end

  def then_i_should_see_my_friends_permissions
    expect(page).to have_text "jimbo"
  end

  def when_i_check_bypass_fogging
    expect(page).to have_css("label#bypass-fogging-2")
    find(:css, "label#bypass-fogging-2").trigger("click")
  end

  def when_i_check_bypass_delay
    expect(page).to have_css("label#bypass-delay-2")
    find(:css, "label#bypass-delay-2").trigger("click")
  end

  def when_i_choose_disable
    find(:css, "label#disallowed-2").trigger("click")
  end

  def then_bypass_fogging_should_be_checked
    bypass_fogging = find("input#bypass-fogging-2")
    expect(bypass_fogging).to be_checked
  end

  def then_bypass_delay_should_be_checked
    bypass_delay = find("input#bypass-delay-2")
    expect(bypass_delay).to be_checked
  end

  def then_disabled_should_be_chosen
    disallowed = find("input#disallowed-2")
    expect(disallowed).to be_checked
  end
end
