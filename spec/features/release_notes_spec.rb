require "rails_helper"

RSpec.feature "ReleaseNotes", type: :feature do
  let(:admin) { create :user, admin: true }
  let!(:release_note) { create :release_note }

  background do
    given_i_am_signed_in
    and_i_am_on_the_release_notes_page
  end

  scenario "Admin creates a release note" do
    when_i_click_add
    and_i_fill_in_release_note_attributes
    and_i_click_add
    then_i_should_see_the_release_note
  end

  scenario "Admin edits a release note" do
    given_i_click_edit
    and_i_fill_in_release_note_attributes
    and_i_click_update
    then_i_should_see_the_release_note
  end

  scenario "Admin deletes a release note" do
    given_i_click_delete
    then_i_should_not_see_the_release_note
  end

  def given_i_am_signed_in
    visit "/users/sign_in"
    fill_in "user_email", with: admin.email
    fill_in "user_password", with: admin.password
    click_button "Log in"
  end

  def and_i_am_on_the_release_notes_page
    click_on "Release notes"
  end

  def when_i_click_add
    click_on "add"
  end

  def and_i_fill_in_release_note_attributes
    fill_in "release_note_version", with: "1.0.0"
    fill_in "release_note_content", with: "some changes"
    fill_in "release_note_created_at", with: Time.current
  end

  def and_i_click_add
    click_button "Add"
  end

  def then_i_should_see_the_release_note
    expect(page).to have_text "some changes"
  end

  def then_i_should_not_see_the_release_note
    expect(page).not_to have_text "Delete"
  end

  def given_i_click_edit
    click_on "mode_edit"
  end

  def and_i_click_update
    click_button "Update"
  end

  def given_i_click_delete
    click_on "Delete"
  end
end
