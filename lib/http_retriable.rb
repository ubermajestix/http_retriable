require "http_retriable/version"
module HttpRetriable

  extend self

  def retry_http(*args, &block)
    options = args.extract_options!
    default_exceptions = [
      EOFError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::EPIPE,
      Errno::ETIMEDOUT]
    if defined?(RestClient)
      default_exceptions += [RestClient::RequestTimeout, RestClient::ServerBrokeConnection]
    end

    retries = options.fetch(:retries, 5)
    should_sleep = options.fetch(:sleep, false)
    backoff = !should_sleep # if sleep is provided by the user, don't backoff
    exceptions = options.fetch(:exceptions, default_exceptions)
    quick_retries = options.fetch(:quick_retries, 2)
    logger = options.fetch(:logger, Logger.new($stderr))

    retried = 0
    quick_retried = 0
    seconds_to_sleep = should_sleep ? should_sleep : 2
    begin
      yield
    rescue *exceptions => e
      if backoff
        if quick_retried < quick_retries
          quick_retried += 1
          logger.debug("[HTTP_RETRIABLE] quick retry: #{quick_retried}/#{quick_retries}") 
          retry
        elsif retried < retries
          retried += 1
          seconds_to_sleep = 2 ** retried
          logger.debug("[HTTP_RETRIABLE] backoff retry: #{retried}/#{retries} sleeping for: #{seconds_to_sleep}s") 
          sleep seconds_to_sleep
          retry
        else
          raise e
        end
      else
        if retried < retries
          logger.debug("[HTTP_RETRIABLE] retry: #{retried}/#{retries} sleeping for: #{seconds_to_sleep}s") 
          retried += 1
          sleep seconds_to_sleep
          retry
        else
          raise e
        end
      end
    end
  end

  def self.call(*args, &block)
    self.retry_http(*args, &block)
  end
end

