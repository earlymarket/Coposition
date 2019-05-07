require "rails_helper"

RSpec.describe WelcomeController, type: :controller do
  describe "#index" do
    it "should render the users placeholder" do
      get :index
      expect(response).to render_template("placeholder_users")
    end
  end

  describe "#index" do
    it "should render the users placeholder" do
      get :devs
      expect(response).to render_template("placeholder_devs")
    end
  end

  describe "#help" do
    it "should render the FAQ page" do
      get :help
      expect(response).to render_template("help")
    end
  end
end
