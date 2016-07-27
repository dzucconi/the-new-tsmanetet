require 'byebug'
require 'ruby-progressbar'
require 'prawn'
require 'prawn/measurement_extensions'
require 'text/hyphen'
require_relative './document'
require_relative './shuffle'
require_relative './print'

name = ARGV.first
  .split('/')
  .last
  .downcase
  .gsub /[^0-9a-z ]/i, '-'

filename = "./output/#{name}_#{Time.now.to_i}"

document_options = {
  width: 5.83.in,
  height: 8.26.in,
  margins: {
    top: 0.5.in,
    outer: 0.5.in,
    inner: 0.5.in,
    bottom: 0.75.in
  }
}

margins = document_options[:margins]

Prawn::Document.generate("#{filename}.pdf", {
  page_size: [document_options[:width], document_options[:height]],
  margin: [margins[:top], margins[:outer], margins[:bottom], margins[:inner]]
}) do |pdf|

  pdf.font_families.update(
    'serif' => {
      normal: './fonts/TimesNewRomanMTStd.ttf'
    },
    'sans' => {
      normal: './fonts/Union.ttf'
    }
  )

  pdf.font :serif

  print 'Processing...'

  output = ARGF.read

  hyphenator = Text::Hyphen.new

  lines = output.split "\n"
  progress = ProgressBar.create starting_at: 0, total: lines.size
  output = lines.map { |line|
    progress.increment
    line.split(' ').map { |token| hyphenator.visualize token, Prawn::Text::SHY }.join ' '
  }.join "\n"

  # Shuffled
  output.gsub!(/(\w+)/) { |word| shuffle word }

  # Books
  output.gsub!(/^(.+)$\n-----/) { |book| "<font name='sans' size='11'>#{$1}</font>\n-----" }

  # Chapter headings
  output.gsub!(/(^C[\w#{Prawn::Text::SHY}]+\s\d+$)/) { |n| "<font name='sans'>#{n}</font>" }

  # Verse numbers
  output.gsub!(/(^\d+)\s/) { |n| "<font name='sans' size='6'>#{n}</font>" }

  File.write "#{filename}_manuscript.txt", output

  print 'Building PDF...'

  pdf.run_before_new_page do |pdf, options|
    print '.', false

    if pdf.page_number.odd? # Count is started at 0, so offset by one
      options[:right_margin] = margins[:inner]
      options[:left_margin] = margins[:outer]
    else
      options[:left_margin] = margins[:inner]
      options[:right_margin] = margins[:outer]
    end
  end

  output.split('-----').map.with_index do |section, i|
    print "Starting section #{i} @ page #{pdf.page_number}"

    pdf.column_box([0, pdf.cursor], reflow_margins: true, columns: 2, width: pdf.bounds.width) do |columns|
      pdf.text section.strip, {
        inline_format: true,
        leading: 0,
        kerning: true,
        size: 8,
        align: :justify
      }
    end

    pdf.start_new_page
    pdf.start_new_page if pdf.page_number.even?
  end

  pdf.font :sans

  pdf.number_pages '<page>', {
    at: [0, -10],
    align: :center,
    start_count_at: 1,
    color: '000000',
    size: 11
  }
end
