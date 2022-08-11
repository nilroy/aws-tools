#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib") unless $LOAD_PATH.include?(File.dirname(__FILE__) + "/../lib")

require "libs"

class SecretManager
  def initialize(region: String, action: String, backend: String, name: String,
                 secret_file: String, secret_string: String, kms_key: String, description: String)
    @region = region
    @action = action
    @secret_backend = backend
    @name = name

    unless @action == "read"
      @secret_string = secret_string.nil? ? File.read(secret_file) : secret_string
    end
    unless kms_key.nil?
      if kms_key.split("/").first == "alias"
        @kms_key = kms_key
      else
        @kms_key = "alias/#{kms_key}"
      end
    end

    @description = description
    @log = Custom::CustomLog.instance.log
    case @secret_backend
    when "ssm_parameter_store"
      @secret_client = AWSLibs::SSM.new(region: @region)
    end
  end

  def main
    begin
      case @action
      when "create"
        create_secret
      when "read"
        read_secret
      when "update"
        update_secret
      when "delete"
        delete_secret
      end
    rescue Custom::CustomException => e
      @log.error(e.message)
    end
  end

  def create_secret
    begin
      @secret_client.create_secret(name: @name, description: @description, value: @secret_string, key_id: @kms_key, overwrite: false)
    rescue Custom::CustomException => exception
      @log.error(exception.message)
    end
  end

  def read_secret
    begin
      secret = @secret_client.read_secret(name: @name)
      puts(secret)
    rescue Custom::CustomException => exception
      @log.error(exception.message)
    end
  end

  def update_secret
    begin
      @secret_client.create_secret(name: @name, description: @description, value: @secret_string, key_id: @kms_key, overwrite: true)
    rescue Custom::CustomException => exception
      @log.error(exception.message)
    end
  end

  def delete_secret
    @log.info("Not implemented")
  end
end

if __FILE__ == $PROGRAM_NAME
  valid_actions = %w[create read update delete]
  valid_backends = %w[ssm_parameter_store secret_manager]

  cli_opts = Optimist.options do
    banner <<-EOF
      This script does CRUD operation over secrets stored in AWS SSM parameter store/Secrets manager
  
      Usage:
         #{$PROGRAM_NAME} [options]
         where [options] are:
      EOF

    opt :region, "Region", type: :string, default: "eu-north-1"
    opt :action, "Action: #{valid_actions.join("/")}", type: :string
    opt :backend, "Backend: #{valid_backends.join("/")}", type: :string, default: "ssm_parameter_store"
    opt :name, "Secret name", type: :string
    opt :secret_file, "Absolute path of file containing a secret", type: :string, default: nil
    opt :secret_string, "Secret String", type: :string, default: nil
    opt :kms_key, "KMS key id/alias to encrypt or decrypt the secret", type: :string, default: nil
    opt :description, "Descripton about the secret", type: :string, default: nil
  end

  Optimist.die :action, "Invalid action! Valid actions are #{valid_actions.join("/")}" unless valid_actions.include?(cli_opts[:action])

  Optimist.die :name, "Provide name of the secret" unless cli_opts[:name]

  Optimist.die :secret_file, "Provide either of secret_file or secret_string" unless cli_opts[:secret_string] || cli_opts[:action] == "read" || cli_opts[:secret_file]

  Optimist.die :secret_string, "Provide either of secret_file or secret_string" unless cli_opts[:secret_string] || cli_opts[:action] == "read" || cli_opts[:secret_file]

  secret_manager = SecretManager.new(region: cli_opts[:region], action: cli_opts[:action], backend: cli_opts[:backend],
                                     name: cli_opts[:name], secret_string: cli_opts[:secret_string],
                                     secret_file: cli_opts[:secret_file],
                                     kms_key: cli_opts[:kms_key], description: cli_opts[:description])
  secret_manager.main
end
