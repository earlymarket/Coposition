require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  include CityMacros

  let(:user) { FactoryGirl::create(:user) }
  let(:developer) { FactoryGirl::create(:developer) }
  let(:checkin) { FactoryGirl::create(:checkin) }


  describe '#humanize_date' do
    it 'should accept a date' do
      expect { helper.humanize_date(Faker::Date.forward(30)) }.not_to raise_error
    end

    it 'should return a string' do
      expect( helper.humanize_date(Faker::Date.forward(30)).class ).to eq(String)
    end
  end

  describe '#area_name' do
    it 'returns a message if there are no near cities' do
      expect(helper.area_name(checkin)).to match('No nearby cities')
    end

    it 'returns the name of the nearest city when there is one' do
      create_denhams
      expect(helper.area_name(checkin)).to match('Denham')
    end
  end

  describe '#fogged_icon' do
    it 'returns different icons depending on a boolean input' do
      expect(helper.fogged_icon(true)).not_to eq(helper.fogged_icon(false))
      expect(helper.fogged_icon(true)).to match('icon')
      expect(helper.fogged_icon(false)).to match('icon')
    end
  end

  describe '#render_flash' do
    it 'should render an alert as a toast notification' do
      flash[:alert] = Faker::Lorem.sentence
      expect{ helper.render_flash }.not_to raise_error
      expect(helper.render_flash).to match(flash[:alert])
      expect(helper.render_flash.length).to be > flash[:alert].length

      # Make sure the alert is being marked for discard after rendering
      # Otherwise the toast will appear on every subsequent page

      expect(flash.instance_values['discard'].instance_values['hash'].keys.include? 'alert').to be true
    end

    it 'should render a notice as a toast notification' do
      flash[:notice] = Faker::Lorem.sentence
      expect{ helper.render_flash }.not_to raise_error
      expect(helper.render_flash).to match(flash[:notice])
      expect(helper.render_flash.length).to be > flash[:notice].length
      expect(flash.instance_values['discard'].instance_values['hash'].keys.include? 'notice').to be true
    end

    it 'should render a bunch of error messages in the flash as toasts' do
      errors = []
      Faker::Number.between(1, 9).times do
        errors << Faker::Lorem.sentence
      end
      flash[:errors] = errors
      expect{ helper.render_flash }.not_to raise_error

      # Make sure each error is being rendered
      rendered_count = 0
      rendered = helper.render_flash

      errors.each do |error|
        rendered_count += 1 if rendered.match(error)
      end

      expect(errors.count).to eq(rendered_count)
      expect(rendered.length).to be >  errors.inject(:+).length
      expect(flash.instance_values['discard'].instance_values['hash'].keys.include? 'errors').to be true
    end
  end

end
