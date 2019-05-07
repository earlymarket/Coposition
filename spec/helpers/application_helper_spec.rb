require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include CityMacros

  let(:user) { create(:user) }
  let(:developer) { create(:developer) }
  let(:checkin) { create(:checkin) }

  describe '#humanize_date and #humanize_date_and_time' do
    it 'should accept a date' do
      [:humanize_date, :humanize_date_and_time].each do |humanize|
        expect { helper.send(humanize, Faker::Date.forward(30)) }.not_to raise_error
      end
    end

    it 'should return a string' do
      [:humanize_date, :humanize_date_and_time].each do |humanize|
        expect(helper.send(humanize, Faker::Date.forward(30)).class).to eq(String)
      end
    end
  end

  describe '#attribute_icon' do
    it 'returns different icons depending on a boolean input' do
      expect(helper.attribute_icon(true, 'cloud') && helper.attribute_icon(false, 'cloud')).to match('icon')
      expect(helper.attribute_icon(true, 'public')).not_to eq(helper.attribute_icon(false, 'public'))
      expect(helper.attribute_icon(true, 'timer')).not_to eq(helper.attribute_icon(true, 'visibility'))
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
end
