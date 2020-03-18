require "logone/gaefe/rails/logger"
require 'logger'

module Logone
  module Gaefe
    class Rails::Middleware
      def initialize(app, filename = "")
        @app = app
        if filename == ""
          filename = "/var/log/app_engine/custom_logs/application.json"
        end
        @logdev = ::Logger::LogDevice.new(filename)
        @logger = Logone::Gaefe::Rails.new(@logdev)
        Rails.logger = @logger
      end
      def call(env)
        Rails.logger.start()
        status, headers, body = @app.call(env)
      ensure
        Rails.logger.end(env, status, headers)
        [status, headers, body]
      end
    end
  end
end
