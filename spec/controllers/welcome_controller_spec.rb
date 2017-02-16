require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe '#index' do
    it 'should render the index under normal circumstances' do
      get :index
      expect(response).to render_template('index')
    end

    it 'should render the placeholder in production' do
      Rails.env = 'production'
      get :index
      Rails.env = 'test'
      expect(response).to render_template('welcome/placeholder_users')
    end

    it 'should let you bypass the placeholder if you set something on admin' do
      Rails.env = 'production'
      get :index, params: { admin: 'true' }
      Rails.env = 'test'
      expect(response).to render_template('welcome/placeholder_users')
    end
  end

  describe '#help' do
    it 'should render the FAQ page' do
      get :help
      expect(response).to render_template('help')
    end
  end
end
