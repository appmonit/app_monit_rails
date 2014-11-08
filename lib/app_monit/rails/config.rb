module AppMonit
  module Rails
    class Config
      class << self
        attr_writer :enabled, :name, :skipped_endpoints

        def enabled?
          @enabled.nil? ? ::Rails.env != "test" : @enabled
        end

        def name
          @name.nil? ? ::Rails.application.class.parent_name : @name
        end

        def skipped_endpoints
          @skipped_endpoints ||= []
        end
      end
    end
  end
end
