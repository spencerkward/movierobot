require 'dalli'

class RemotePersister
  TIMEOUT_S = 10
  MAX_ATTEMPTS = 1000
  KEY = "json"

  def initialize
    server = ENV['MEMCACHE_SERVERS'] || 'localhost:11211'
    user = ENV['MEMCACHE_USERNAME']
    password = ENV['MEMCACHE_PASSWORD']

    puts "Connecting to dalli server #{server}, username #{user}, password #{password}"
    cache = Dalli::Client.new server, :username => user, :password => password
    @dalli_cache = UnreliableObjectDelegate.new cache, TIMEOUT_S, MAX_ATTEMPTS
  end

  def reset
    puts "* RESETTING REMOTE CACHE"
    @dalli_cache.delete KEY
  end

  def save data
    puts "* SAVING DATA TO REMOTE CACHE: #{data}"
    @dalli_cache.set KEY, data
    data
  end

  def retrieve
    data = @dalli_cache.get KEY
    puts "* RETRIEVING DATA FROM REMOTE CACHE #{data}"
    data
  end
end
