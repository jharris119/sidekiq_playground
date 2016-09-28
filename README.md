# sidekiq_playground
Playing with sidekiq

### Server side

~~~sh
bundle exec sidekiq -r ./worker.rb
~~~

### Then client side

~~~sh
bundle exec pry -r ./worker.rb

[1] pry(main)> DoIt.start
~~~

You'll see the output on the server side.
