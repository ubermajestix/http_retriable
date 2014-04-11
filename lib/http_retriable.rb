require "http_retriable/version"
require 'logger'
class HttpRetriable

  def self.call(opts={}, &block)
    retriable = self.new(opts)
    begin
      yield(retriable)
    rescue *retriable.exceptions => e
      retriable.retry? ? retry : raise(e)
    end
  end

  attr_reader :retries, :quick_retries, :retried, :quick_retried,
    :seconds_to_sleep, :exceptions

  def initialize(options={})
    @retries = options.fetch(:retries, 5)
    @quick_retries = options.fetch(:quick_retries, 2)
    @backoff = options.fetch(:backoff, true)
    @seconds_to_sleep = options.fetch(:sleep, 2)
    @exceptions = options.fetch(:exceptions, self.class.default_exceptions)
    @retried = 0
    @quick_retried = 0
  end

  def self.default_exceptions
    exceptions = [
      EOFError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::EPIPE,
      Errno::ETIMEDOUT
    ]
    if defined?(RestClient)
      exceptions += [RestClient::RequestTimeout, RestClient::ServerBrokeConnection]
    end
    exceptions
  end

  def retry?
    if quick_retry?
      quick_retry! 
      true
    elsif retried < retries
      retry! 
      true
    else
      false
    end
  end

  def backoff?
    !!@backoff
  end

  def quick_retry?
    quick_retries > 0 && quick_retried < quick_retries
  end

private

  def quick_retry!
    @quick_retried += 1
    logger.info("[HTTP_RETRIABLE] quick retry: #{quick_retried}/#{quick_retries}") 
  end

  def retry!
    @retried += 1
    @seconds_to_sleep = 2 ** retried if backoff?
    logger.info("[HTTP_RETRIABLE] backoff retry: #{retried}/#{retries} sleeping for: #{seconds_to_sleep}s") 
    sleep seconds_to_sleep
  end

  def logger
    return @logger if defined? @logger
    if defined? Rails
      @logger = Rails.logger
    else
      @logger = ::Logger.new($stdout)
    end
  end
end
