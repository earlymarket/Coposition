require "rails_helper"

RSpec.feature "Devices", type: :feature do

  let(:user) { FactoryGirl.create :user }

  background do
    given_I_am_signed_in
  end

  scenario "User creates then deletes device" do
    and_I_create_a_new_device
    when_I_click_delete
    then_I_should_see_no_devices
  end

  # JAVASCRIPT
  # scenario "User creates device and edits settings with javascript enabled", js: true do
  #   and_I_create_a_new_device
  #   then_I_should_see_the_device_map
  #   and_I_am_on_the_devices_page
  #   when_I_click_the_icon "cloud"
  #   then_I_should_see "Location fogging is off"
  #   when_I_click_the_icon "public"
  #   then_I_should_see "Location sharing is on"
  #   when_I_click_the_icon "visibility_off"
  #   then_I_should_see "Device cloaking is on"
  #   when_I_click_the_icon "timer"
  #   and_I_click_the_slider
  #   then_I_should_see "is delayed by"
  # end

  def given_I_am_signed_in
    visit "/users/sign_in"
    fill_in "user_email", with: user.email
    fill_in "user_password", with: user.password
    click_button "Log in"
  end

  def and_I_am_on_the_devices_page
    visit "/users/#{user.id}/devices/"
    expect(page).to have_text("Your devices")
    expect(page).to have_text("Device info")
  end

  def and_I_create_a_new_device
    visit "/users/#{user.id}/devices/new"
    expect(page).to have_text("Device Creation")
    fill_in "device_name", with: "My device"
    click_button "Add"
  end

  def then_I_should_see_the_device_map
    expect(page).to have_text("Checkin now")
  end

  def when_I_click_the_icon(icon)
    click_link(icon, match: :first)
  end

  def then_I_should_see(text)
    expect(page).to have_text(text)
  end

  def and_I_click_the_slider
    find(:class, ".noUi-origin").click
  end

  def when_I_click_delete
    click_link "Delete device"
  end

  def then_I_should_see_no_devices
    expect(page).to have_text("Your devices")
    expect(page).not_to have_text("Device info")
  end

end
