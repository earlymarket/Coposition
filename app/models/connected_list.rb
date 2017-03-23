class ConnectedList
  REDIS_KEY = "connected_nodes"

  def self.redis
    @redis ||= ::Redis.new(url: ActionCableConfig[:url])
  end

  def self.all
    redis.smembers(REDIS_KEY)
  end

  def self.clear_all
    redis.del(REDIS_KEY)
  end

  def self.add(user_id)
    redis.sadd(REDIS_KEY, user_id)
  end

  def self.include?(user_id)
    redis.sismember(REDIS_KEY, user_id)
  end

  def self.remove(user_id)
    redis.srem(REDIS_KEY, user_id)
  end
end
