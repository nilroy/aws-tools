#!/usr/bin/env ruby

module AWSLibs
  class SSM
    def initialize(region: String)
      @region = region
      @aws_ssm_client = Aws::SSM::Client.new(region: @region)
    end

    def create_secret(name: String, description: String, value: String, key_id: String, overwrite: Bool)
      begin
        @aws_ssm_client.put_parameter({
          name: name,
          description: description,
          value: value,
          key_id: key_id,
          type: "SecureString",
          overwrite: overwrite
        })
      rescue => exception
        msg = format("Error creating SSM paramater. Error Message: %{error}", error: exception.message)
        raise Custom::CustomException, msg
      end
    end
  end
end
