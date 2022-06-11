# HttpRetriable

 HttpRetriable is designed to catch routine http errors and retry the provided
 block that makes network calls.

 By default, requests are tried 5 times with an exponential backoff to
 prevent thrashing a service that may need a few seconds to recover. It
 will retry your call twice without a sleep before backing off and
 retrying again. The number of quick retries is configurable.

 You can optionally provide a constant amount of time to sleep between retries
 and provide the number of times to retry the request if 5 retries doesn't suit
 your neeeds.

 Unlike other libraries that provide a similar function this does not polute
 Kernal or Object with additional methods. You can include or extend HttpRetriable
 for use within your own class or module, or you can call the module directly,
 examples are below.

## Examples:

### Calling directly:

```ruby
def get_funny_cats(id)
  HttpRetriable.call do
    LulzService.get("/cats/lulz/#{id}")
  end
end
```

### Mixing it in:

```ruby
class FunnyCats

  include HttpRetriable

  def get_funny_cats(id)
    retry_http do
      LulzService.get("/cats/lulz/#{id}")
    end
  end
end
```

### Options
 You can provide several options:
   * retries          - Integer: The number of times to retry the request
   * quick_retries    - Integer: The number of times to retry the request without backing off.
   * sleep            - Integer: The number of seconds to sleep
   * exceptions       - Array: List of exceptions classes

```ruby
def get_funny_cats(id)
  exceptions = [LulzService::Error, Timeout::Error]
  HttpRetriable.call(:retries => 3, :sleep => 10, :exceptions => exceptions) do
    LulzService.get("/cats/lulz/#{id}")
  end
end
```

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
