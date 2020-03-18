# Logone::Gaefe::Rails

The library is the logger that supported structured logging per request in GAEFE.

## Installation

```ruby
gem 'logone-gaefe-rails', git: 'https://github.com/hixi-hyi/logone-gaefe-rails.git'
```

And then execute:

    $ bundle


## ToDO / 問題点
* The library was written by a person of beginner level lerning ruby / rails / rack.
* It's experimental version. Log messages are temporarily stored in memory. Be careful in below point on a huge system.
    * Memory usage.
    * The log is not written out until the function ends.

## Usage

#### development
```
config.middleware.insert_after(0, Logone::Gaefe::Rails::Middleware, STDOUT)
```

#### production
```
config.middleware.insert_after(0, Logone::Gaefe::Rails::Middleware)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hixi-hyi/logone-gaefe-rails.
