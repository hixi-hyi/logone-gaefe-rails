require 'time'
require 'json'

module Logone
  module Gaefe
    class Rails
      attr_accessor :formatter # not implementation
      attr_accessor :level # not implementation

      def initialize(logger)
        @logger = logger
        @formatter = '' # not implementation
        @level = 'debug' # not implementation
      end

      def thread_val
        thread_key = @thread_key ||= "Logone::Gaefe::Rails::#{object_id}".freeze
        Thread.current[thread_key] ||= {}
      end

      def set(key, value)
        thread_val[key] = value
      end

      def get(key)
        thread_val[key]
      end

      def start()
        thread_val.clear
        set("severity", "DEBUG")
        set("logline", Logone::Gaefe::Rails::Logline.new)
        set("startTime", Time.now)
      end

      def write(requestlog)
        @logger.write(requestlog.to_json + "\n")
      rescue
        STDERR.puts(requestlog)
      end

      def end(env, status, headers)
        headers ||= {}
        endTime = Time.now
        traceId = "-"
        if env["HTTP_X_CLOUD_TRACE_CONTEXT"] != nil
          traceId = env["HTTP_X_CLOUD_TRACE_CONTEXT"].split("/")[0]
        end
        ip = "-"
        if env["HTTP_X_FORWARDED_FOR"] != nil
          ip = env["HTTP_X_FORWARDED_FOR"].split(", ")[0] 
          # 本当はこれじゃだめ。自分の管理する IP の中で後ろから辿れなきゃいけないけど、 Google Front End とかいてやっかいなので、まぁとりあえず
        end

        requestlog = {
          :@type            => "type.googleapis.com/google.appengine.logging.v1.RequestLog",
          :appId            => "s~#{ENV['GCLOUD_PROJECT']}",
          :serviceId        => ENV['GAE_SERVICE'],
          :versionId        => ENV['GAE_VERSION'],
          :instanceId       => ENV['GAE_INSTANCE'],
          :ip               => ip,
          :startTime        => get('startTime').utc.iso8601(6),
          :endTime          => endTime.utc.iso8601(6),
          :latency          => (endTime - get('startTime')).to_s + "s",
          :status           => status || "-",
          :responseSize     => "-",
          :userAgent        => env["HTTP_USER_AGENT"],
          :host             => env["HTTP_HOST"],
          :method           => env["REQUEST_METHOD"],
          :resource         => env["REQUEST_URI"],
          :httpVersion      => env["HTTP_VERSION"],
          :traceId          => traceId,
          :requestId        => headers["X-Request-Id"] || "-",
          :line             => get('logline').log,
          :severity         => get('severity'),
          #:megaCycles       => "",
          #:urlMapEntry      => "",
          #:instanceIndex    => "",
          #:appEngineRelease => "",
          #:cost             => "",
        }
        if value = headers && headers['Content-Length']
          requestlog[:responseSize] = value
        end
        write(requestlog)
      ensure
        thread_val.clear
      end

      def add(severity, message = nil, progname = nil, &block)
        addline(severity, message, caller.first)
      end

      def addline(severity, message, call = nil)
        set('severity', calc_severity(get('severity'), severity))
        get('logline').add(severity, message, call)
      end

      def debug(message = nil)
        addline("DEBUG", message, caller.first)
      end

      def info(message = nil)
        addline("INFO", message, caller.first)
      end

      def warn(message = nil)
        addline("WARNING", message, caller.first)
      end

      def crit(message = nil)
        addline("CRITICAL", message, caller.first)
      end

      def error(message = nil)
        addline("ERROR", message, caller.first)
      end

      def fatal(message = nil)
        addline("CRITICAL", message, caller.first)
      end

      # 本当は頭良くやりたいけどもとりあえず
      # https://github.com/ruby/ruby/blob/trunk/lib/logger.rb
      def calc_severity(prev, current)
        if prev == "CRITICAL"
          return prev
        elsif prev == "ERROR" && current == "CRITICAL"
          return current
        elsif prev == "WARNINGS" && (current == "CRITICAL" || current == "ERROR")
          return current
        elsif prev == "INFO" && (current == "CRITICAL" || current == "ERROR" || current == "WARNING")
          return current
        elsif prev == "DEBUG" && (current == "CRITICAL" || current == "ERROR" || current == "WARNING" || current == "INFO")
          return current
        end
        return current
      end
    end

    class Rails::Logline
      attr_reader :log
      def initialize
        @log = []
      end
      def add(severity, message = nil, call = nil)
        line = {}
        line[:severity] = severity
        line[:logMessage] = message
        line[:time] = Time.now.utc.iso8601(6)
        if call
          line[:caller] = parse_caller(call)
        end
        @log << line
      end

      def parse_caller(at)
        if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
          file = $1
          line = $2.to_i
          method = $3
          "#{file} - #{method} (line:#{line})"
        end
      end
    end
  end
end
