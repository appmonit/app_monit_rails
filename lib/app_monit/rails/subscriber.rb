module AppMonit
  module Rails
    class Subscriber

      class << self
        def register
          ActiveSupport::Notifications.subscribe /process_action/, self.new
        end
      end

      def call(*args)
        event = ActiveSupport::Notifications::Event.new(*args)

        payload  = event.payload
        endpoint = "#{payload[:controller]}##{payload[:action]}"
        minute   = event.time.to_i - (event.time.to_i % 60)

        if payload[:exception]
          trigger_error(minute, endpoint, event.duration.to_i)
          trigger_error(minute, 'total', event.duration.to_i)
        else
          durations = { total: event.duration.to_i, view: payload[:view_runtime].to_i,
                        db:    payload[:db_runtime].to_i, ext: payload[:ext_runtime].to_i }
          trigger_event(minute, endpoint, durations)
          trigger_event(minute, 'total', durations)
        end
      end

      # @return [AppMonit::Worker]
      def worker
        AppMonit::Rails::Worker.instance
      end

      def trigger_error(minute, endpoint, duration)
        event = AppMonit::Rails::Error.new(minute, endpoint, duration)
        AppMonit::Rails.logger.debug event
        worker.push(event)
      end

      def trigger_event(minute, endpoint, durations)
        event = AppMonit::Rails::Event.new(minute, endpoint, durations)
        AppMonit::Rails.logger.debug event
        worker.push(event)
      end
    end
  end
end
