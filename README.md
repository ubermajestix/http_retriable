# HttpRetriable

HttpRetriable is designed to catch routine http errors and retry the
provided block that makes network calls.

Its very general purpose and simple. It can easily retry any block of
code a set number of times, sleeping each time it's retried.

Out of the box its designed to sleep with an exponentaial backoff after
making 5 quick retries without sleeping.

This is useful for network operations where there may have been a
momentary glitch, but it will start to backoff if a service is getting
thrashed, giving the service time to recover and hopefully complete your request.


##Examples:

```ruby
class FunnyCatClient
  def self.get(id)
    HttpRetriable.call do
      RestClient.get("https://api.cheezburger.com/v1/assets/#{id}")
    end
  end
end

### Options
 You can provide several options:
   * retries          - Integer: The number of times to retry the request
   * quick_retries    - Integer: The number of times to retry the request without backing off.
   * sleep            - Integer: The number of seconds to sleep
   * exceptions       - Array: List of exceptions classes. Defaults to common network exceptions
   * backoff          - Boolean: Turn exponential backoff on or off. Defaults to true.

def get_funny_cats(id)
  exceptions = [LulzService::Error, Timeout::Error]
  # Retries the block of code 3 times if any of the provided exceptions are raised. 
  # Sleeps for 10 seconds between retries. 
  # Does not execute quick retries.
  HttpRetriable.call(:retries => 3, :sleep => 10, :quick_retries => 0, :exceptions => exceptions) do
    LulzService.get("/cats/lulz/#{id}")
  end
end
```

## Backwards Compatibility

Version 1.0.0 is not backwards compatible with 0.0.3. The mixin
capability was removed for simplicity.

## Installation

Add this line to your application's Gemfile:

    gem 'http_retriable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_retriable

## Contributing

1. Fork it.
2. Branch it.
3. Code it.
4. Pull Request it.
