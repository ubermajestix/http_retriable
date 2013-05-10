require "http_retriable/version"

module HttpRetriable

  extend self

  def retry_http(*args, &block)
    options = args.extract_options!
  
    options[:retries] ||= 5
    options[:sleep] ||= 0
    exceptions = options.fetch(:exceptions, [
      RestClient::RequestTimeout,
      RestClient::ServerBrokeConnection,
      EOFError,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::EPIPE,
      Errno::ETIMEDOUT,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      SocketError,
      Timeout::Error])

    retried = 0
    begin
      yield
    rescue *exceptions => e
      if retried + 1 < options[:retries]
        retried += 1
        sleep options[:sleep]
        retry
      else
        raise e
      end
    end
  end

  def self.call(*args, &block)
    self.retry_http(args, &block)
  end
end

