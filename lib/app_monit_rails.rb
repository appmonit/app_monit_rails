require 'app_monit'
module AppMonit
  module Rails
    Event = Struct.new(:minute, :endpoint, :durations)
    Error = Struct.new(:minute, :endpoint, :duration)

    require 'app_monit/rails/config'
    require 'app_monit/rails/subscriber'
    require 'app_monit/rails/railtie'
    require 'app_monit/rails/worker'

    class << self
      def logger
        @logger ||= ::Rails.env.test? ? Logger.new($STDOUT) : Logger.new('log/app_monit_rails.log')
      end
    end
  end
end
