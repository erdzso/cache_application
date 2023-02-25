# frozen_string_literal: true

##
# This class responsible to read and provide api calling related configuration
class ApiCallingConfiguration
  include Singleton

  def initialize
    reset
  end

  def expiration_time
    @expiration_time ||= configuration[:expiration_time] || 120
  end

  def movies_client_api_key
    @movies_client_api_key ||= configuration[:movies_client_api_key]
  end

  def configuration
    @configuration ||= YAML.load(File.read(Rails.root.join('config/api_calling_configuration.yml')))
  end

  def reset
    instance_variables.each do |variable|
      instance_variable_set(variable, nil)
    end
  end
end
