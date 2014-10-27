module AppMonit
  module Rails
    class Config
      class << self
        attr_writer :enabled

        def enabled?
          @enabled.nil? ? ::Rails.env != "test" : @enabled
        end
      end
    end
  end
end
