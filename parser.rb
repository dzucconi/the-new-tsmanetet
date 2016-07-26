require 'byebug'
require 'prawn'
require 'ruby-progressbar'

class Object
  def identity(*args)
    self
  end
end

module Parser
  ABBREVIATIONS = {
    gen: "Genesis",
    exo: "Exodus",
    lev: "Leviticus",
    num: "Numbers",
    deu: "Deuteronomy",
    jos: "Joshua",
    jdg: "Judges",
    rut: "Ruth",
    sa1: "1 Samuel",
    sa2: "2 Samuel",
    kg1: "1 Kings",
    kg2: "2 Kings",
    ch1: "1 Chronicles",
    ch2: "2 Chronicles",
    ezr: "Ezra",
    neh: "Nehemiah",
    est: "Esther",
    job: "Job",
    psa: "Psalms",
    pro: "Proverbs",
    ecc: "Ecclesiastes",
    sol: "Song of Solomon",
    isa: "Isaiah",
    jer: "Jeremiah",
    lam: "Lamentations",
    eze: "Ezekiel",
    dan: "Daniel",
    hos: "Hosea",
    joe: "Joel",
    amo: "Amos",
    oba: "Obadiah",
    jon: "Jonah",
    mic: "Micah",
    nah: "Nahum",
    hab: "Habakkuk",
    zep: "Zephaniah",
    hag: "Haggai",
    zac: "Zechariah",
    mal: "Malachi",
    es1: "1 Esdras",
    es2: "2 Esdras",
    tob: "Tobias",
    jdt: "Judith",
    aes: "Additions to Esther",
    wis: "Wisdom",
    bar: "Baruch",
    epj: "Epistle of Jeremiah",
    sus: "Susanna",
    bel: "Bel and the Dragon",
    man: "Prayer of Manasseh",
    ma1: "1 Macabees",
    ma2: "2 Macabees",
    ma3: "3 Macabees",
    ma4: "4 Macabees",
    sir: "Sirach",
    aza: "Prayer of Azariah",
    lao: "Laodiceans",
    jsb: "Joshua B",
    jsa: "Joshua A",
    jdb: "Judges B",
    jda: "Judges A",
    toa: "Tobit BA",
    tos: "Tobit S",
    pss: "Psalms of Solomon",
    bet: "Bel and the Dragon Th",
    dat: "Daniel Th",
    sut: "Susanna Th",
    ode: "Odes",
    mat: "Matthew",
    mar: "Mark",
    luk: "Luke",
    joh: "John",
    act: "Acts",
    rom: "Romans",
    co1: "1 Corinthians",
    co2: "2 Corinthians",
    gal: "Galatians",
    eph: "Ephesians",
    phi: "Philippians",
    col: "Colossians",
    th1: "1 Thessalonians",
    th2: "2 Thessalonians",
    ti1: "1 Timothy",
    ti2: "2 Timothy",
    tit: "Titus",
    plm: "Philemon",
    heb: "Hebrews",
    jam: "James",
    pe1: "1 Peter",
    pe2: "2 Peter",
    jo1: "1 John",
    jo2: "2 John",
    jo3: "3 John",
    jde: "Jude",
    rev: "Revelation"
  }

  BREAK = "\n\n-----\n"
  INDENT = Prawn::Text::NBSP * 2

  class << self
    def each(line, previous = {}, output = '', i = 0)
      match = /^(\w+)\|(\w+)\|(\w+)\|\s(.+)$/.match line
      book = ABBREVIATIONS[match[1].downcase.to_sym]
      chapter = match[2]
      verse = match[3]
      body = match[4].strip.gsub(/~$/, "\n")

      if book != previous[:book]
        output += "#{i == 0 ? '' : BREAK + "\n"}#{book.upcase}#{BREAK}"
        previous[:book] = book
      end

      if chapter != previous[:chapter]
        output += "\nCHAPTER #{chapter}\n\n"
        previous[:chapter] = chapter
      end

      output += "#{verse} #{body}"

      [previous, output]
    end

    def parse(source, out, take = nil)
      lines = File.readlines source
      progress = ProgressBar.create starting_at: 0, total: lines.size
      output = ''
      previous = {}

      lines
        .send(take.nil? ? :identity : :take, take).each_with_index do |line, i|
          progress.increment

          previous, output = each line, previous, output, i
        end

      File.write out, output
    end
  end
end
