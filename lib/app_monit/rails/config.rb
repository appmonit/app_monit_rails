module AppMonit
  class Rails
    class Config
      class << self
        attr_writer :enabled

        def enabled?
          @enabled.nil? ? env != "test" : @enabled
        end
      end
    end
  end
end
