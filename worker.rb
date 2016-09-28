require 'sidekiq'
require 'redis'

Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
end

DEFAULT_THREAD_COUNT = 25

module MyWorkers
  class WorkerAlpha
    include Sidekiq::Worker

    def perform(id)
      puts "Starting thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
      sleep 5
      puts "Finished thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
    end
  end

  class WorkerBravo
    include Sidekiq::Worker

    def perform(id)
      puts "Starting thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
      sleep 5
      puts "Finished thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
    end
  end
end

class DoIt
  def self.start
    Redis.new.flushdb
    puts "Creating 20 alphas and 5 bravos"

    40.times do |t|
      MyWorkers::WorkerAlpha.perform_async(t)
    end
    5.times do |t|
      MyWorkers::WorkerBravo.perform_async(t)
    end

    puts "client done!"
  end
end
