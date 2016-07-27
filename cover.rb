# Usage: `ruby cover.rb title width height spine_width`
# eg. `ruby cover.rb "The New Testament" 12.651 8.514 0.734`

require 'byebug'
require 'prawn'
require 'prawn/measurement_extensions'
require_relative './shuffle'
require_relative './print'

title = shuffle_all ARGV.first
width, height, spine_width = ARGV[1..-1].map &:to_f
spine_start = ((width - spine_width) / 2)

bleed = 0.125.in
font_size = 11

name = ARGV.first.downcase.gsub /[^0-9a-z ]/i, '-'
filename = "./output/#{name}_cover_#{Time.now.to_i}.pdf"

Prawn::Document.generate(filename, {
  page_size: [width.in, height.in],
  margin: [0.5.in, 0.in, 1.in, 0.in]
}) do |pdf|
  print 'Building PDF...'

  pdf.font './fonts/Union.ttf'
  pdf.text_box title.upcase, {
    leading: 0,
    kerning: true,
    size: font_size,
    at: [spine_start.in + spine_width.in + 0.5.in, pdf.bounds.top - bleed]
  }

  pdf.text_box title.upcase, {
    leading: 0,
    kerning: true,
    size: font_size,
    at: [
      spine_start.in + (spine_width.in / 2) + ((font_size / 2.0).floor - 1).pt,
      pdf.bounds.top - bleed
    ],
    rotate: 270
  }

  print 'Done'
end
