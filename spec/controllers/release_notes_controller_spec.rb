require "rails_helper"

RSpec.describe Users::ReleaseNotesController, type: :controller do
  include ControllerMacros

  let!(:user) do
    create_user
    User.last.update(admin: true)
    User.last
  end
  let!(:release_note) { create :release_note }

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

    it "redirects if user is not admin" do
      user.update(admin: false)
      get :new
      expect(response).to redirect_to(root_path)
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

    it "redirects if user is not admin" do
      user.update(admin: false)
      post_create
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #edit" do
    let(:get_edit) { get :edit, params: { id: release_note.id } }

    it "assigns release note" do
      get_edit
      expect(assigns(:release_note)).to eq release_note
    end

    it "redirects if user is not admin" do
      user.update(admin: false)
      get_edit
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #notify" do
    let(:post_notify) { post :notify, params: { id: release_note.id } }

    it "calls firebase push" do
      allow(Firebase::Push).to receive(:call)
      post_notify
      expect(Firebase::Push).to have_received(:call)
    end

    it "redirects if user is not admin" do
      user.update(admin: false)
      post_notify
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PUT #update" do
    let(:put_update) { put :update, params: { id: release_note.id, release_note: { application: "android" } } }

    it "update release note with provided params" do
      expect { put_update }.to change { ReleaseNote.find(release_note.id).application }.to "android"
    end

    it "redirects if user is not admin" do
      user.update(admin: false)
      put_update
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) { delete :destroy, params: { id: release_note.id } }

    it "deletes release note" do
      expect { delete_destroy }.to change { ReleaseNote.count } .by(-1)
    end

    it "redirects if user is not admin" do
      user.update(admin: false)
      delete_destroy
      expect(response).to redirect_to(root_path)
    end
  end
end
