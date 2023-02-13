require_relative 'app/red_catalyst_web'
ENV['RECORD_PATH'] = "#{settings.root}/public/record"
run RedCatalyst.new