require 'json'
require 'sneakers'
require 'sneakers/metrics/newrelic_metrics'
require 'newrelic_rpm'

require './lib/utils/application'

Sneakers::Metrics::NewrelicMetrics.eagent ::NewRelic

Sneakers.configure(
    amqp: app_config.rabbit.amqp,
    pid_path: "./pids/linear_demand_worker.pid",
    metrics: Sneakers::Metrics::NewrelicMetrics.new(),
    env: nil
)

Sneakers.logger.level = Logger::WARN

# Requeues messages from dead letter
class SimpleWorker
  include Sneakers::Worker

  from_queue app_config.simple_worker.queue_name,
             exchange: app_config.simple_worker.exchange_name,
             timeout_job_after: app_config.simple_worker.timeout,
             exchange_type: app_config.simple_worker.exchange_type, #'topic',
             log: app_config.simple_worker.log, #'./log/_worker.log',
             routing_key: app_config.simple_worker.routing_key

  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def work(msg)
    puts 'started undead worker'
    msg = JSON.parse(msg)
    return actual_work(msg)
  rescue Exception => e
    puts "#{self.class.name}#work: #{e}"
    puts e.backtrace
    ::NewRelic::Agent.agent.error_collector.notice_error( e )
    return reject!
  end

  def actual_work(msg)
    # Do the actual work
    #puts "#{self.class.name}#finish"
    ack! #you must acknowledge, reject or requeue the messages
  end

  add_transaction_tracer :actual_work, :name => 'simple_worker', :params => 'args[0]' #:params => 'args[0]' is not always required can cause exceptions
end