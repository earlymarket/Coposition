require "rails_helper"

RSpec.feature "Devices", type: :feature do
  let(:user) { create_user }
  let(:device) { FactoryGirl.create :device, user_id: user.id }

  scenario "User creates device" do
    given_I_am_on_the_devices_page
    and_I_create_a_new_device
    then_I_should_see_the_device_map
  end

  scenario "User edits device settings" do
    given_I_am_on_the_devices_page
    and_I_have_a_device
    and_I_edit_device("fogged")
    then_I_should_see_attribute_updated("fogged")
    and_I_edit_device("cloaked")
    then_I_should_see_attribute_updated("cloaked")
    and_I_edit_device("shared")
    then_I_should_see_attribute_updated("shared")
    and_I_edit_device("delayed")
    then_I_should_see_attribute_updated("delayed")
    and_I_edit_device("name")
    then_I_should_see_attribute_updated("name")
  end

  scenario "User deletes device" do

  end

  def given_I_am_on_the_devices_page
    visit "/users/#{user.id}devices/"
  end

  def and_I_create_a_new_device
    visit "users/#{user.id}/devices/new"
    fill_in "device[name]", with: "laptop"
    click_button "Add"
  end

  def then_I_should_see_the_device_map
    expect(page).to have_text("Checkin now")
  end

  def and_I_have_a_device
    device
  end

  def and_I_edit_device(attribute)
    if attribute == "delayed"
      device.update delayed: 60
    elsif attribute == "name"
      device.update name: "mobile"
    else
      device[attribute] = !device[attribute]
      device.save
    end
  end

  def then_I_should_see_attribute_updated(attribute)
    if attribute == "delayed"
      expect(page).to have_text("Checkin now")
    elsif attribute == "name"
      expect(page).to have_text("mobile now")
    else
      device[attribute] = !device[attribute]
      device.save
    end
end
