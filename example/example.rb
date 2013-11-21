$:<<'../lib'

require 'win-path-utils'

path = WinPathUtils::Path.new

path_value = path.get

# We store it before we can mess it
File.open "path_backup.txt", "a+" do |f|
  f << path_value << "\n"
end

puts "Your %Path% is:", path_value

puts "Appending something to the %Path%..."
path.append('C:\devenv\bin')

puts "%Path% now is:", path.get
