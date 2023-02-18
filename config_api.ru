require_relative 'app/red_catalyst_api'
ENV['RECORD_PATH'] = "#{settings.root}/public/record"
run RedCatalystAPI.new