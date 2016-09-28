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

    VICTORY = %{
  _______AAAA_______________AAAA________
         VVVV               VVVV
         (__)               (__)
          \ \               / /
           \ \   \\|||//   / /
            > \   _   _   / <
   hang      > \ / \ / \ / <
    in        > \\_o_o_// <
    there...   > ( (_) ) <
                >|     |<
               / |\___/| \
               / (_____) \
               /         \
                /   o   \
                 ) ___ (
                / /   \ \
               ( /     \ )
               ><       ><
              ///\     /\\\
              '''       '''
    }

    def perform(id)
      puts "Starting thingy #{self.class.to_s}[#{id}]/job[#{self.jid}]"
      puts VICTORY
      sleep 5
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

    puts "creating 5 bravos on the slow queue"
    5.times do
      bravos += 1
      MyWorkers::WorkerBravo.perform_async(bravos)
    end

    puts "run for three minutes."
    puts "add an alpha to the default queue every second so the default queue always consumes all 25 threads"
    start = Time.now.to_i
    loop do
      break if Time.now.to_i - start > 180

      alphas += 1
      MyWorkers::WorkerAlpha.perform_async(alphas)
    end

    puts "client done!"
  end
end
