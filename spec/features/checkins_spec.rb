require "rails_helper"

RSpec.feature "Checkins", type: :feature do
  background do
    given_i_am_signed_in
    and_i_have_a_device
  end

  scenario "User checks in then deletes history", js: true do
    when_i_right_click_on_the_map
    and_i_click_create_checkin_here
    then_i_should_have_a_checkin
    and_i_click_delete_checkins
    and_i_click_delete_all
    then_i_should_have_no_checkins
  end

  scenario "User edits checkin fogging and deletes", js: true do
    when_i_right_click_on_the_map
    and_i_click_create_checkin_here
    and_i_click_on_the_checkin
    then_i_should_see_fogged_info
    when_i_click_fogging
    then_i_should_not_see_fogged_info
    when_i_click_delete
    then_i_should_have_no_checkins
  end

  def given_i_am_signed_in
    visit "/users/sign_up"
    fill_in "user_email", with: "tommo@email.com"
    fill_in "user_email_confirmation", with: "tommo@email.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_username", with: Faker::Internet.user_name(4..20, %w(_ -))
    click_on "Sign up"
  end

  def and_i_have_a_device
    click_on "Devices", match: :first
    click_on "add"
    fill_in "device_name", with: "My_device"
    find("div.select-wrapper input").click
    find("div.select-wrapper li", text: "Laptop").click
    click_button "Add"
  end

  def when_i_right_click_on_the_map
    sleep 2
    find("#map").right_click
  end

  def and_i_click_create_checkin_here
    click_on "Create checkin here"
  end

  def then_i_should_have_a_checkin
    expect(page).to have_selector "img.leaflet-marker-icon"
  end

  def and_i_click_delete_checkins
    find("a.delete").trigger("click")
  end

  def and_i_click_delete_all
    find("a.delete-all").trigger("click")
  end

  def then_i_should_have_no_checkins
    expect(page).not_to have_selector "img.leaflet-marker-icon"
  end

  def and_i_click_on_the_checkin
    find("img.leaflet-marker-icon").click
  end

  def when_i_click_fogging
    click_link "cloud"
  end

  def when_i_click_delete
    click_link "delete_forever"
  end

  def then_i_should_see_fogged_info
    expect(page).to have_text "Fogged Address"
  end

  def then_i_should_not_see_fogged_info
    expect(page).not_to have_text "Fogged Address"
  end
end
