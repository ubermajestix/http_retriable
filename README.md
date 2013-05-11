# HttpRetriable

 HttpRetriable is designed to catch routine http errors and retry the provided
 block that makes network calls.

 By default, requests are tried 5 times with an exponential backoff to prevent
 thrashing a service that may need a few seconds to recover.

 You can optionally provide a constant amount of time to sleep between retries
 and provide the number of times to retry the request if 5 retries doesn't suit
 your neeeds.

 Unlike other libraries that provide a similar function this does not polute
 Kernal or Object with additional methods. You can include or extend HttpRetriable
 for use within your own class or module, or you can call the module directly,
 examples are below.

 Examples:

 Calling directly:

```ruby
def get_funny_cats(id)
  HttpRetriable.call do
    LulzService.get("/cats/lulz/#{id}")
  end
end
```

 Mixing it in:

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

 You can provide several options:
   retries    - Integer: The number of times to retry the request
   sleep      - Integer: The number of seconds to sleep
   exceptions - Array: List of exceptions classes

 Example:

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

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
