require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include CityMacros

  let(:user) { FactoryGirl.create(:user) }
  let(:developer) { FactoryGirl.create(:developer) }
  let(:checkin) { FactoryGirl.create(:checkin) }

  describe '#humanize_date' do
    it 'should accept a date' do
      expect { helper.humanize_date(Faker::Date.forward(30)) }.not_to raise_error
    end

    it 'should return a string' do
      expect(helper.humanize_date(Faker::Date.forward(30)).class).to eq(String)
    end
  end

  describe '#fogged_icon' do
    it 'returns different icons depending on a boolean input' do
      expect(helper.fogged_icon(true) && helper.fogged_icon(false)).to match('icon')
      expect(helper.fogged_icon(true)).not_to eq(helper.fogged_icon(false))
    end
  end

  describe '#render_flash' do
    it 'should render an alert and a notice as a toast notification' do
      [:alert, :notice].each do |type|
        flash[type] = Faker::Lorem.sentence
        expect { helper.render_flash }.not_to raise_error
        expect(helper.render_flash).to match(flash[type])
        expect(helper.render_flash.length).to be > flash[type].length

        # Make sure the alert is being marked for discard after rendering
        # Otherwise the toast will appear on every subsequent page

        expect(flash.instance_values['discard'].instance_values['hash'].keys.include?(type.to_s)).to be true
      end
    end

    it 'should render a bunch of error messages in the flash as toasts' do
      errors = []
      Faker::Number.between(1, 9).times do
        errors << Faker::Lorem.sentence
      end
      flash[:errors] = errors
      expect { helper.render_flash }.not_to raise_error

      # Make sure each error is being rendered
      rendered_count = 0
      rendered = helper.render_flash

      errors.each do |error|
        rendered_count += 1 if rendered.match(error)
      end

      expect(errors.count).to eq(rendered_count)
      expect(rendered.length).to be >  errors.inject(:+).length
      expect(flash.instance_values['discard'].instance_values['hash'].keys.include?('errors')).to be true
    end
  end

  describe '#name_or_email_name' do
    it 'should return the start of the users email if no username' do
      user.update(username: '')
      expect(user.email).to include helper.name_or_email_name(user)
    end

    it 'should return the username user has a username' do
      expect(helper.name_or_email_name(user)).to match user.username
    end
  end
end
