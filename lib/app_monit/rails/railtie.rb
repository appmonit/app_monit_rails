module AppMonit
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do |app|
        if AppMonit::Rails::Config.enabled?
          AppMonit::Rails::Subscriber.register
          AppMonit::Rails.logger.debug '[RAILSRUNNER] started'
        end
      end
    end
  end
end
