module AppMonit
  module Rails
    class Config
      class << self
        attr_writer :enabled

        def enabled?
          @enabled.nil? ? ::Rails.env != "test" : @enabled
        end

        def name
          @name.nil? ? ::Rails.application.class.parent_name : @name
        end
      end
    end
  end
end
