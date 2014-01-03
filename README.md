Fluentd adapter for Yell

If you are not yet familiar with **Yell - Your Extensible Logging Library** 
check out the github project under https://github.com/rudionrails/yell or jump 
directly into the Yell wiki at https://github.com/rudionrails/yell/wiki.

## Installation

System wide:

```console
gem install yell-adapters-fluentd```

Or in your Gemfile:

```ruby
gem "yell-adapters-fluentd"
```

## Usage

The Fluentd adapter is based on the GELF adapter at https://github.com/rudionrails/yell-adapters-gelf

```ruby
logger = Yell.new :fluentd

# or alternatively with the block syntax
logger = Yell.new do |l|
  l.adapter :fluentd
end

logger.info 'Hello World!'
```

By default, the adapter will send the following information to Fluentd:

`level`: The current log level  
`timestamp`: The time when the log event occured  
`host`: The current hostname  
`file`: The name of the file where the log event occured  
`line`: The line in the file where the log event occured  
`_method`: The method where the log event occured  
`_pid`: The PID of your current process

### Example: Running Fluentd on a different host or port

```ruby
logger = Yell.new :fluentd, :host => '127.0.0.1', :port => 1234

# or with the block syntax
logger = Yell.new do |l|
  l.adapter :fluentd, :host => '127.0.0.1', :port => 1234
end

logger.info 'Hello World!'
```

### Example: Using a custom tag
By default, the tag "yell" is used. This can be overridden for custom handling.

```ruby
logger = Yell.new :fluentd, :tag => 'yell.custom'

# or with the block syntax
logger = Yell.new do |l|
  l.adapter :fluentd, :tag => 'yell.custom'
end

logger.info 'Hello World!'
```

### Example: Passing additional keys to the adapter

```ruby
logger = Yell.new :fluentd

logger.info "Hello World", "_thread_id" => Thread.current.object_id, 
                           "_current_user_id" => current_user.id
```