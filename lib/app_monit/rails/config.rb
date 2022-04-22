module AppMonit
  module Rails
    class Config
      class << self
        attr_writer :enabled, :name, :skipped_endpoints

        def enabled?
          @enabled.nil? ? ::Rails.env != 'test' : @enabled
        end

        def name
          module_parent_name = if Rails::VERSION::MAJOR >= 6
                                 ::Rails.application.class.module_parent_name
                               else
                                 ::Rails.application.class.parent_name
                               end

          @name.nil? ? module_parent_name : @name
        end

        def skipped_endpoints
          @skipped_endpoints ||= []
        end
      end
    end
  end
end
