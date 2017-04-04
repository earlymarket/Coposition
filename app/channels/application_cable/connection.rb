module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id

    def connect
      self.user_id = find_verified_user_id
      logger.add_tags 'ActionCable', user_id
    end

    protected

    def find_verified_user_id
      if (verified_user = env['warden'].user)
        verified_user.id
      else
        reject_unauthorized_connection
      end
    end
  end
end
