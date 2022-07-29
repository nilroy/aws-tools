#!/usr/bin/env ruby

module Custom
    class CustomException < RuntimeError
    end

    class CustomLog
        include Singleton
        attr_accessor :log
        def initialize
            @log = Logger.new(STDOUT)
            @log.level = Logger::DEBUG
        end
    end
end

