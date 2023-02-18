require_relative './seeds/production.rb'

if ENV['RACK_ENV'] == 'test'
    require_relative './seeds/test.rb'
end