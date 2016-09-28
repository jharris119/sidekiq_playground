Notes
=====

~~~rb
40.times do |t|
  MyWorkers::WorkerAlpha.perform_async(t)
end
5.times do |t|
  MyWorkers::WorkerBravo.perform_async(t)
end
~~~

Sidekiq starts the Alpha workers first, and it doesn't start the Bravo workers until all of the Alpha workers have started. However, it doesn't run the Alpha workers in the order that they're created, and it doesn't run the Bravo workers in the order that they're created.

- - -

Now we have two queues, the default one with a priority of 5 and a "slow" queue with a priority of 1. Both queues have at least 25 jobs on them, so either one would consume all of Sidekiq's threads. It looks like sidekiq pulls jobs off the default queue at slightly more than 5x the rate that pulls jobs off the slow queue. _Notably, the slow queue is not completely impeded by the overwhelmed fast queue._
