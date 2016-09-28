require 'sidekiq'
require 'redis'

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
end

class OurWorker
  include Sidekiq::Worker

  DEFAULT_THREAD_COUNT = 25
  
  def self.go()
    Redis.new.flushdb
    
    puts "creating #{DEFAULT_THREAD_COUNT} thingies"
    DEFAULT_THREAD_COUNT.times do |t|
      self.perform_async(t + 1)
    end
    puts "waiting three seconds..."
    sleep 3
    puts "creating 10 more thingies"
    10.times do |t|
      self.perform_async(t + 26)
    end
    puts "done!"
  end

  def perform(id)
    puts "Starting thingy #{id}"
    sleep 5
    puts "Finished thingy #{id}"
  end
end
