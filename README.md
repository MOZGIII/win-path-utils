# WinPathUtils

This gem allows you to manupulate Windows' system `PATH` variable via registry.
It provides convenient methods to add and remove items to `PATH`.

## Installation

Add this line to your application's Gemfile:

    gem 'win-path-utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install win-path-utils

## Usage

```ruby
require 'win-path-utils'

path = WinPathUtils::Path.new

# Get the PATH
path_value = path.get      # => "C:\Ruby\bin;C:\..."

# Append something
path.append('C:\test\at\the\end')

# Prepend something
path.prepend('C:\test\at\the\beginning')

# Get the PATH now - it's updated
new_path_value = path.get  # => "C:\test\at\the\beginning;C:\Ruby\bin;C:\..."

# Remove something
path.remove('C:\test')
```

Just read the code, it's pretty straightforward.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
