module Env
  def env(env = nil)
    Env.env(env)
  end

  def self.env(env = nil)
    if env
      @env = env.to_sym
    end
      @env ||= (ENV['RACK_ENV'] || ENV['RUBY_ENV'] || 'development').to_sym
  end
end
