# encoding: utf-8
require 'yell'
require 'fluent-logger'

module Yell
	module Adapters
		class Fluentd < Yell::Adapters::Base

			attr_accessor :tag, :host, :port
			attr_accessor :log

			setup do |options|
				@host = (options[:host] || 'localhost')
				@port = (options[:port] || 24224)
				@tag = (options[:tag] || "yell")

				connect
			end

			close do
				@log.close if @log
			end

			write do |event|
				connect

				message = format({
					'version' => '1.0',
					'level' => Severities[event.level],
					'timestamp' => event.time.to_f,
					'host' => event.hostname,
					'file' => event.file,
					'line' => event.line,
					'_method' => event.method,
					'_pid' => event.pid
				}, *event.messages )

				log.post(tag, message)
			end

			def connect
				@log ||= Fluent::Logger::FluentLogger.new(nil, :host => (@host || 'localhost'), :port => (@port || 24224))
			end

			def format( *messages )
				messages.inject(Hash.new) do |result, m|
					result.merge to_message(m)
				end
			end

			def to_message( message )
				case message
					when Hash
						message
					when Exception
						{ "short_message" => "#{message.class}: #{message.message}" }.tap do |m|
							m.merge!( "long_message" => message.backtrace.join("\n") ) if message.backtrace
						end
					else { "short_message" => message.to_s }
				end
			end
		end

		register(:fluentd, Yell::Adapters::Fluentd)
	end
end
