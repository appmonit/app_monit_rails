module AppMonit
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'app_monit.configure' do |app|
        AppMonit::Rails::Subscriber.register
        AppMonit::Rails.logger.debug '[RAILSRUNNER] started'
      end
    end
  end
end
