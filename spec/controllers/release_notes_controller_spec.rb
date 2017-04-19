require "rails_helper"

RSpec.describe Users::ReleaseNotesController, type: :controller do
  include ControllerMacros

  let!(:user) do
    create_user
    User.last.update(admin: true)
    User.last
  end
  let!(:release_note) { FactoryGirl.create :release_note }

  describe "GET #index" do
    it "assigns release notes" do
      get :index
      expect(assigns(:release_notes)).to eq [release_note]
    end

    it "filters release notes by application if application provided" do
      get :index, params: { application: "api" }
      expect(assigns(:release_notes)).to eq []
    end
  end

  describe "GET #new" do
    it "assigns new release note" do
      get :new
      expect(assigns(:release_note)).to be_kind_of ReleaseNote
    end
  end

  describe "POST #create" do
    let(:post_create) { post :create, params: { release_note: { version: "1.0.1", application: "api" } } }

    it "creates a new release note" do
      expect { post_create }.to change { ReleaseNote.count }.by 1
    end

    it "creates a new release note with provided params" do
      post_create
      expect(ReleaseNote.first.version).to eq "1.0.1"
    end
  end

  describe "GET #edit" do
    it "assigns release note" do
      get :edit, params: { id: release_note.id }
      expect(assigns(:release_note)).to eq release_note
    end
  end

  describe "PUT #update" do
    it "update release note with provided params" do
      expect {
        put :update, params: { id: release_note.id, release_note: { application: "mobile" } }
      }.to change { ReleaseNote.find(release_note).application }.to "mobile"
    end
  end

  describe "DELETE #destroy" do
    it "deletes release note" do
      expect { delete :destroy, params: { id: release_note.id } }.to change { ReleaseNote.count } .by(-1)
    end
  end
end
