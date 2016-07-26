require './parser'

name = ARGV.first
  .split('/')
  .last
  .split('.')
  .first
  .downcase
  .gsub /[^0-9a-z ]/i, '-'

n = ARGV.last.to_i
n = n.zero? ? nil : n

# eg. Parser.parse 'sources/kjvdat.txt', 'output/kjv.txt', 500
Parser.parse ARGV.first, "./output/#{name}.txt", n
