def print(x, b = true)
  STDOUT.write "#{b ? "\n" : ''}#{x}#{b ? "\n" : ''}"
end
