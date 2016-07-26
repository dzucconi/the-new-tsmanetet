require 'rspec'
require_relative '../parser'

describe 'Parser' do
  describe '#each' do
    it 'keeps track of results of the line' do
      line = 'Gen|1|1| In the beginning God created the heaven and the earth.~'
      previous, output = Parser.each line

      expect(previous[:book]).to eq 'Genesis'
      expect(previous[:chapter]).to eq '1'
    end

    it 'it builds an output out of consecutive lines' do
      line = 'Gen|1|1| In the beginning God created the heaven and the earth.~'
      line_2 = 'Gen|1|2| And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.~'

      previous, output = Parser.each line

      expect(output).to eq %q{GENESIS

-----

1

	1: In the beginning God created the heaven and the earth.
}

      previous, output = Parser.each line_2, previous, output
      expect(output).to eq %q{GENESIS

-----

1

	1: In the beginning God created the heaven and the earth.
	2: And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.
}
    end
  end
end
