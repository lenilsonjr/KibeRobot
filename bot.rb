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
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

stream.filter(follow: "#{ENV["TRACK_ACCOUNT_ID"]}") do |object|
  if object.user.screen_name == ENV["TRACK_ACCOUNT"] && object.is_a?(Twitter::Tweet)
    kibe = client.search("\"#{object.text}\"", result_type: "recent").take(100)

    if !kibe.empty?
      puts "We found a copycat"
      kibe = kibe.last
      text = "@#{object.user.screen_name} Opa, eu já vi esse tweet antes 🤔 @#{kibe.user.screen_name} #{kibe.uri}" 
      client.update(text, :in_reply_to_status => object)
    end
  end
end