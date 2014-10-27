module AppMonit
  module Rails
    class Worker
      MUTEX          = Mutex.new
      MAX_MULTIPLIER = 5

      attr_accessor :requests, :errors

      class << self
        def instance
          return @instance if @instance
          MUTEX.synchronize do
            return @instance if @instance
            @instance = new.start
          end
        end
      end

      def initialize
        @queue      = Queue.new
        @multiplier = 1
        @flush_rate = 60
        reset
      end

      def reset
        @requests = Hash.new do |requests, minutes|
          requests[minutes] = Hash.new do |minute, endpoints|
            minute[endpoints] = Hash.new do |endpoint, duration|
              endpoint[duration] = { sum: 0, count: 0, average: 0 }
            end
          end
        end
        @errors   = Hash.new do |errors, minutes|
          errors[minutes] = Hash.new do |minute, endpoint|
            minute[endpoint] = { sum: 0, count: 0, average: 0 }
          end
        end
      end

      def current_minute
        time = Time.now.to_i
        time - (time % 60)
      end

      def start
        Thread.new do
          while (event = @queue.pop)
            begin
              case event
                when Error
                  update_error(event)
                when Event
                  update_event(event)
                when :flush
                  send_to_collector
              end
            rescue Exception => e
              AppMonit::Rails.logger.debug ["Event error:", event.inspect, e.message]
            end
          end
        end
        start_flusher

        self
      end

      def update_error(event)
        bucket           = @errors[event.minute][event.endpoint]
        bucket[:sum]     += event.duration
        bucket[:count]   += 1
        bucket[:average] = (bucket[:sum] / bucket[:count].to_f)
      end

      # @param [AppMonit::Rails::Event] event
      def update_event(event)
        event.durations.each do |duration, value|
          bucket           = @requests[event.minute][event.endpoint][duration]
          bucket[:sum]     += value
          bucket[:count]   += 1
          bucket[:average] = (bucket[:sum] / bucket[:count].to_f)
        end
      end

      def start_flusher
        Thread.new do
          loop do
            sleep @multiplier * @flush_rate
            push(:flush)
          end
        end
      end

      def push(event)
        @queue << event
      end

      def convert_requests_to_events
        @requests.flat_map do |minute, endpoints|
          endpoints.collect do |endpoint, durations|
            payload = durations.merge(application: Config.name, endpoint: endpoint)
            { application: Config.name, created_at: Time.at(minute), name: 'page_load', payload: payload }
          end
        end
      end

      def convert_errors_to_events
        @errors.flat_map do |minute, endpoints|
          endpoints.collect do |endpoint, duration|
            payload = duration.merge(application: Config.name, endpoint: endpoint)
            { created_at: Time.at(minute), name: 'page_error', payload: payload }
          end
        end
      end

      def events
        convert_requests_to_events + convert_errors_to_events
      end

      def send_to_collector
        AppMonit::Rails.logger.debug "Sending to collector"

        if events.any?
          AppMonit::Http.post('/v1/events', event: events)

          @requests.clear
          @errors.clear
        end

        reset
      end
    end
  end
end
