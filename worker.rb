require 'sidekiq'
require 'sidekiq/api'   # contains Sidekiq::Queue
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
    sidekiq_options queue: 'default'

    def perform(id)
      puts "Starting thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
      sleep 6
      puts "Finished thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
    end
  end

  class WorkerBravo
    include Sidekiq::Worker
    sidekiq_options queue: 'slow'

    def perform(id)
      puts "Starting thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
      sleep 6
      puts "Finished thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
    end
  end
end

class DoIt
  def self.start
    puts "Queues: #{Sidekiq::Queue.all}"

    Redis.new.flushdb

    alphas = 0
    bravos = 0

    puts "creating 25 alphas to consume all threads on the default queue"
    25.times do |t|
      alphas += 1
      MyWorkers::WorkerAlpha.perform_async(alphas)
    end

    puts "creating 25 bravos on the slow queue"
    25.times do
      bravos += 1
      MyWorkers::WorkerBravo.perform_async(bravos)
    end

    puts "run for three minutes."
    puts "add an alpha and bravo to their respective queues every second to keep them full"
    start = Time.now.to_i
    loop do
      break if Time.now.to_i - start > 180

      alphas += 1
      MyWorkers::WorkerAlpha.perform_async(alphas)

      bravos += 1
      MyWorkers::WorkerBravo.perform_async(bravos)
    end

    puts "client done!"
  end
end
