require 'twitter'
require 'dotenv/load'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

stream = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['WATCHER_ACCESS_TOKEN']
  config.access_token_secret = ENV['WATCHER_ACCESS_TOKEN_SECRET']
end

puts "Starting up..."
account_ids = ENV["TRACK_ACCOUNTS_IDS"].split(',')
stream.filter(follow: "#{ENV["TRACK_ACCOUNTS_IDS"]}") do |object|
  if object.is_a?(Twitter::Tweet) && account_ids.include?(object.user.id) 
    kibe = client.search("\"#{object.text}\" -filter:retweets", result_type: "recent").take(100)

    if !kibe.empty?
      puts "We found a copycat"
      kibe = kibe.last
      text = "@#{object.user.screen_name} Opa, eu já vi esse tweet antes 🤔 @#{kibe.user.screen_name} #{kibe.uri}" 
      begin
        client.update(text, :in_reply_to_status => object)
      rescue Twitter::Error::Forbidden
        puts "Tamo block"
      end
      text = "Esse tweet de @#{object.user.screen_name} se parece bastante com outro de @#{kibe.user.screen_name} #{object.uri}" 
      tweet = client.update(text)
      client.update("@KibeRobot #{kibe.uri}", :in_reply_to_status => tweet)
    end
  end
end

puts "Done!"
