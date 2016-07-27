def shuffle word
  case word.size
  when 1, 2, 3
    word
  else
    shuffle = ->(word) {
      chars = word.chars
      chars.first +
      chars[1..-2].shuffle.join('') +
      chars.last
    }

    shuffled = shuffle.call word

    tries = 1

    while word == shuffled do
      break if tries > 50
      shuffled = shuffle.call word
      tries = tries + 1
    end

    shuffled
  end
end

def shuffle_all string
  string.gsub(/(\w+)/) { |word| shuffle word }
end
