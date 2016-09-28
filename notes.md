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
