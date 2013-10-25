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

    retried = 0
    seconds_to_sleep = should_sleep ? should_sleep : 2
    quick_retries = 2
    begin
      yield
    rescue *exceptions => e
      retried += 1
      if backoff
        if retried < quick_retries
          retry
        elsif retried < retries
          seconds_to_sleep = seconds_to_sleep ** 2
          sleep seconds_to_sleep
          retry
        else
          raise e
        end
      else
        if retried < retries
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

