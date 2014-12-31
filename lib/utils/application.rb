require 'yaml'
require 'hashie'
require_relative 'env'


module Application
  extend Env

  class << self
    def config
      @config ||= Hashie::Mash.new(YAML.load_file('./config/application.yml')[env.to_s])
    end
  end
end


def app_config
  Application.config
end
