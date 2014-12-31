require 'newrelic_rpm'
require_relative 'env'

module NewrelicHandler

  class << self
    include Env

    def start_newrelic
      puts "start_newrelic env: #{env}"
      nr_conf = YAML::load_file('./config/newrelic.yml')[env.to_s]
      ::NewRelic::Agent.manual_start  nr_conf
    end

    def stop_newrelic
      puts "stop_newrelic env: #{env}"
      ::NewRelic::Agent.shutdown(force_send: true)
    end

    def report_provider_time(provider, time)
      report "Custom/ProviderTime/#{provider}", time
    end

    def report_timeout(provider)
      report "Custom/Timeout/#{provider}", 1
    end

    def report_provider_served(provider)
      report "Custom/ProviderServed/#{provider}", 1
    end

    def report_auto_complete(success)
      value=success ? "completed" : "no_completion"
      report "Custom/AutoComplete/#{value}", 1
    end

    def report(key, value = 1)
      begin
        stat = ::NewRelic::Agent.agent.stats_engine.get_stats_no_scope(key)
        stat.record_data_point(value)
      rescue Exception => e
        ::NewRelic::Agent.agent.error_collector.notice_error( e )
      end
    end
  end

end
