module Users::Devices
  class DevicesInfoPresenter < ApplicationPresenter
    attr_reader :user
    attr_reader :device
    attr_reader :config

    def initialize(user, params)
      @user = user
      @device = Device.find(params[:id])
      @config = device.config
    end

    def config_rows
      return "<tr><td><i>No additional config</i></td></tr>".html_safe unless custom.present?
      custom.map { |key, value| "<tr><td>#{key}</td><td>#{value}</td></tr>" }.join.html_safe
    end

    private

    def custom
      @custom ||= config.custom
    end
  end
end
