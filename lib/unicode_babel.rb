module UnicodeBabel
require "stringex"

class << self # Only class methods, this is a general utility library
  def latex_inclusions(string)
    locales = babel_locales(string) || []
    locales.push("english")
    maybe_fontenc = if locales.include?("russian") ||  locales.include?("polish")
      "\\usepackage[T2A]{fontenc}\n"
    else ''
    end
    maybe_fontenc + "\\usepackage[#{locales.join(",")}]{babel}\n"
  end

  def char_declarations(string)
    chars = []
    string.chars.uniq.each do |letter|
      if locale_to_babel_option(@@locale_map[letter.unpack('U')[0]])
        chars.push(letter)
      end
    end
    chars.map{|c| "\\PrerenderUnicode{#{c}}"}.join("\n")
  end

  def babel_locales(string)
    language_locales(string).map do |locale|
      locale_to_babel_option(locale)
    end.flatten.compact
  end
  def locale_to_babel_option(locale)
    case locale
    when /latin extended-a/
      # ["czech","dutch","polish","turkish"]
      "polish"
    when /latin extended-b/
      # ["afrikaans","croatian","serbian","slovene","romanian"]
      "romanian"
    when /latin-1 supplement/
      "ngerman"
    when /cyrillic/
      # ["bulgarian","ukrainian","russian"]
      "russian"
    when /greek/
      "greek"
    when "hangul"
      # TODO: \usepackage{xeCJK}, install on server
      nil
      # ... and so on
    when /latin|ascii/
      # "english" -- only if nothing else is found, we'll handle this from latex_inclusions for now
    else
      nil
    end
  end

  def language_locales(string)
    locales = {}
    string.chars.uniq.each do |letter|
      locales[@@locale_map[letter.unpack('U')[0]]] = true
    end
    locales.keys.compact
  end

  def activate_foreign_languages(string)
    activated_string = ""
    open_brace = 0
    pending_string = ""
    pending_macros = []

    current_locale = @@locale_map['a'.unpack('U')[0]] # start in English
    current_option = "english"
    deunicode_mode = false

    string.each_char.with_index do |letter,index|
      case letter
      when "{"
        if string[index-1] != '\\'
          if open_brace == 0
            # I hate, hate, hate having to do this... but there seems to be no choice
            # \macro   [ optional stuff ]{many}{mandatory}{arguments}{ <--- we are here?
            # ^
            # ^ and we want to insert the select macro prior the first \
            #
            # 06/22/2016: EXCEPT in cases like \caption{} inside tables, where babel macros wrapping the \caption will BREAK the alignment magic
            #             ... and corrupt the entire export. Make sure we stay inside \caption{ ->here<- }
            if activated_string.match(/\\caption\s*$/)
              activated_string << '{'
            else
              open_pre = 0
              while ((activated_string.length > 0) && (activated_string[-1].match(/^[^\s\\]$/) || (open_pre < 0)))
                # Transfer the last letter to the pending stack
                last_letter = activated_string[-1]
                pending_string.prepend(last_letter)
                # Always chop! after using the letter, as single-char strings are passed by reference
                activated_string.chop!

                # Modify the pre scope counter if needed
                if activated_string[-1] != '\\'
                  case last_letter
                  when "{", "["
                    open_pre+=1
                  when "}", "]"
                    open_pre-=1
                  end
                end
              end
              # This is either the empty string, a space or a backslash. In each case it's safe to move it over
              # but before we do, handle the annoying special case of "\macro    {"
              activated_string.sub!(/\\(\w+\s*)\z/) do
                pending_string.prepend($1)
                "\\"
              end
              last_letter = activated_string[-1]
              pending_string.prepend(last_letter)
              # Always chop! afterr using the letter, as single-char strings are passed by reference
              activated_string.chop!
            end
          end
          open_brace+=1
        end
      when "}"
        if string[index-1] != '\\'
          open_brace-=1

          if open_brace == 0
            first_select = pending_macros.first.to_s.dup
            last_select = pending_macros.last.to_s.dup
            if activated_string.match(/\\caption\s*\{$/) # gotta love special cases...
              last_select << '}'
            end
            activated_string << first_select + pending_string + letter + last_select
            letter = ""
            pending_macros = []
            pending_string = ""
          end
        end
      when /^[^\s,;\.\?!\-\/\:]$/ # don't change locales on safe punctuation
        c_locale = @@locale_map[letter.unpack('U')[0]]
        if (c_locale != current_locale)
          # locale switch, let's update
          deunicode_mode = false
          babel_option = locale_to_babel_option(c_locale)
          select_lang_macro = ""
          if babel_option # We know what we are switching to - do so.
            select_lang_macro = "\\selectlanguage{#{babel_option}}"
          elsif current_option != "english" # We are switching to an unknown mode, so default to English
            select_lang_macro = "\\selectlanguage{english}"
            babel_option = "english"
          else # Default for yet-unsupported by us, or by babel, locales: deunicode to ASCII
            deunicode_mode = true
          end
          # Record the activation outside of any brace scope, if needed
          if open_brace > 0
            pending_macros.push(select_lang_macro)
          else
            activated_string << select_lang_macro
          end
          # Update the current to what we just encountered
          if c_locale # but only if the locale is known
            current_locale = c_locale
            current_option = babel_option
          end
        end
      end

      # Deunicode mode translates each letter downto ascii
      if deunicode_mode
        letter = letter.to_ascii()
      end
      # Always record the letter, this is a lossless copy
      if open_brace > 0
        pending_string << letter
      else
        activated_string << letter
      end
    end
    activated_string << pending_string # flush any remaining pending
    activated_string
  end
end

# We gratefull thank UnicodeScript for inventing these CHARTS for ruby
# Original source: https://github.com/yuri-g/unicode-script/blob/master/lib/unicode_script/charts.rb
CHARTS = {
  'armenian' => (0x0530..0x058f),
  'coptic' => (0x2c80..0x2cff),
  'greek and coptic' => (0x0370..0x03ff),
  'cypriot syllabary' => (0x10800..0x1083f),
  'cyrillic' => (0x0400..0x04ff),
  'cyrillic supplement' => (0x0500..0x052f),
  'cyrillic extended-a' => (0x2de0..0x2dff),
  'cyrillic extended-b' => (0xa640..0xa69f),
  'georgian' => (0x10a0..0x10ff),
  'georgian supplement' => (0x2d00..0x2d2f),
  'hiragana' => (0x3040..0x309f),
  'glagolitic' => (0x2c00..0x2c5f),
  'gothic' => (0x10330..0x1034f),
  'greek extended' => (0x1f00..0x1fff),
  'basic latin' => (0x0000..0x007f),
  'c1 controls and latin-1 supplement' => (0x0080..0x00ff),
  'latin extended-a' => (0x0100..0x017f),
  'latin extended-b' => (0x0180..0x024f),
  'latin extended-c' => (0x2c60..0x2c7f),
  'latin extended-d' => (0xa720..0xa7ff),
  'latin extended additional' => (0x1e00..0x1eff),
  'fullwidth ascii' => (0x0020..0x007e),
  'halfwidth cjk punctuation' => (0x3000..0x303f),
  'halfwidth hangul' => (0x3130..0x318f),
  'linear b syllabary' => (0x10000..0x1007f),
  'linear b ideograms' => (0x10080..0x100ff),
  'ogham' => (0x1680..0x169f),
  'old italic' => (0x10300..0x1032f),
  'phaistos disc' => (0x101d0..0x101ff),
  'runic' => (0x16a0..0x16ff),
  'shavian' => (0x10450..0x1047f),
  'ipa extensions' => (0x0250..0x02af),
  'phonetic extensions' => (0x1d00..0x1d7f),
  'phonetic extensions supplement' => (0x1d80..0x1dbf),
  'modifier tone letters' => (0xa700..0xa71f),
  'spacing modifier letters' => (0x02b0..0x02ff),
  'superscripts and subscripts' => (0x2070..0x209f),
  'combining diacritical marks' => (0x0300..0x036f),
  'combining diacritical marks supplement' => (0x1dc0..0x1dff),
  'combining half marks' => (0xfe20..0xfe2f),
  'bamum' => (0xa6a0..0xa6ff),
  'bamum supplement' => (0x16800..0x16a3f),
  'egyptian hieroglyphs' => (0x13000..0x1342f),
  'ethiopic' => (0x1200..0x137f),
  'ethiopic supplement' => (0x1380..0x139f),
  'ethiopic extended' => (0x2d80..0x2ddf),
  'ethiopic extended-a' => (0xab00..0xab2f),
  'meroitic cursive' => (0x109a0..0x109ff),
  'meroitic hieroglyphs' => (0x10980..0x1099f),
  'nko' => (0x07c0..0x07ff),
  'osmanya' => (0x10480..0x104af),
  'tifinagh' => (0x2d30..0x2d7f),
  'vai' => (0xa500..0xa63f),
  'arabic' => (0x0600..0x06ff),
  'arabic supplement' => (0x0750..0x077f),
  'arabic extended-a' => (0x08a0..0x08ff),
  'arabic presentation forms-a' => (0xfb50..0xfdff),
  'arabic presentation forms-b' => (0xfe70..0xfeff),
  'imperial aramaic' => (0x10840..0x1085f),
  'avestan' => (0x10b00..0x10b3f),
  'carian' => (0x102a0..0x102df),
  'cuneiform' => (0x12000..0x123ff),
  'cuneiform numbers and punctuation' => (0x12400..0x1247f),
  'old persian' => (0x103a0..0x103df),
  'ugaritic' => (0x10380..0x1039f),
  'hebrew' => (0x0590..0x05ff),
  'lycian' => (0x10280..0x1029f),
  'lydian' => (0x10920..0x1093f),
  'mandaic' => (0x0840..0x085f),
  'old south arabian' => (0x10a60..0x10a7f),
  'inscriptional pahlavi' => (0x10b60..0x10b7f),
  'inscriptional parthian' => (0x10b40..0x10b5f),
  'phoenician' => (0x10900..0x1091f),
  'samaritan' => (0x0800..0x083f),
  'syriac' => (0x0700..0x074f),
  'mongolian' => (0x1800..0x18af),
  'old turkic' => (0x10c00..0x10c4f),
  'phags-pa' => (0xa840..0xa87f),
  'tibetan' => (0x0f00..0x0fff),
  'bengali' => (0x0980..0x09ff),
  'brahmi' => (0x11000..0x1107f),
  'chakma' => (0x11100..0x1114f),
  'devanagari' => (0x0900..0x097f),
  'devanagari extended' => (0xa8e0..0xa8ff),
  'gujarati' => (0x0a80..0x0aff),
  'gurmukhi' => (0x0a00..0x0a7f),
  'kaithi' => (0x11080..0x110cf),
  'kannada' => (0x0c80..0x0cff),
  'kharoshthi' => (0x10a00..0x10a5f),
  'lepcha' => (0x1c00..0x1c4f),
  'limbu' => (0x1900..0x194f),
  'malayalam' => (0x0d00..0x0d7f),
  'meetei mayek' => (0xabc0..0xabff),
  'meetei mayek extensions' => (0xaae0..0xaaff),
  'ol chiki' => (0x1c50..0x1c7f),
  'oriya' => (0x0b00..0x0b7f),
  'saurashtra' => (0xa880..0xa8df),
  'sharada' => (0x11180..0x111df),
  'sinhala' => (0x0d80..0x0dff),
  'sora sompeng' => (0x110d0..0x110ff),
  'syloti nagri' => (0xa800..0xa82f),
  'takri' => (0x11680..0x116cf),
  'tamil' => (0x0b80..0x0bff),
  'telugu' => (0x0c00..0x0c7f),
  'thaana' => (0x0780..0x07bf),
  'vedic extensions' => (0x1cd0..0x1cff),
  'balinese' => (0x1b00..0x1b7f),
  'batak' => (0x1bc0..0x1bff),
  'buginese' => (0x1a00..0x1a1f),
  'cham' => (0xaa00..0xaa5f),
  'javanese' => (0xa980..0xa9df),
  'kayah li' => (0xa900..0xa92f),
  'khmer' => (0x1780..0x17ff),
  'khmer symbols' => (0x19e0..0x19ff),
  'lao' => (0x0e80..0x0eff),
  'myanmar' => (0x1000..0x109f),
  'myanmar extended-a' => (0xaa60..0xaa7f),
  'new tai lue' => (0x1980..0x19df),
  'rejang' => (0xa930..0xa95f),
  'sundanese' => (0x1b80..0x1bbf),
  'sundanese supplement' => (0x1cc0..0x1ccf),
  'tai le' => (0x1950..0x197f),
  'tai tham' => (0x1a20..0x1aaf),
  'tai viet' => (0xaa80..0xaadf),
  'thai' => (0x0e00..0x0e7f),
  'buhid' => (0x1740..0x175f),
  'hanunoo' => (0x1720..0x173f),
  'tagalog' => (0x1700..0x171f),
  'tagbanwa' => (0x1760..0x177f),
  'bopomofo' => (0x3100..0x312f),
  'bopomofo extended' => (0x31a0..0x31bf),
  'cjk unified ideographs' => (0x4e00..0x9fcc),
  'cjk unified ideographs extension a' => (0x3400..0x4db5),
  'cjk unified ideographs extension b' => (0x20000..0x2a6d6),
  'cjk unified ideographs extension c' => (0x2a700..0x2b734),
  'cjk unified ideographs extension d' => (0x2b740..0x2b81d),
  'cjk compatibility ideographs' => (0xf900..0xfaff),
  'cjk compatibility ideographs supplement' => (0x2f800..0x2fa1f),
  'kangxi radicals' => (0x2f00..0x2fdf),
  'cjk radicals supplement' => (0x2e80..0x2eff),
  'cjk strokes' => (0x31c0..0x31ef),
  'hangul jamo' => (0x1100..0x11ff),
  'hangul jamo extended-a' => (0xa960..0xa97f),
  'hangul jamo extended-b' => (0xd7b0..0xd7ff),
  'hangul compatibility jamo' => (0x3130..0x318f),
  'katakana' => (0x30a0..0x30ff),
  'katakana phonetic extensions' => (0x31f0..0x31ff),
  'kana supplement' => (0x1b000..0x1b0ff),
  'kanbun' => (0x3190..0x319f),
  'lisu' => (0xa4d0..0xa4ff),
  'miao' => (0x16f00..0x16f9f),
  'yi syllables' => (0xa000..0xa48f),
  'yi radicals' => (0xa490..0xa4cf),
  'cherokee' => (0x13a0..0x13ff),
  'deseret' => (0x10400..0x1044f),
  'unified canadian aboriginal syllabics' => (0x1400..0x167f),
  'unified canadian aboriginal syllabics extended' => (0x18b0..0x18ff)
}

@@locale_map = CHARTS.map do |key, range|
  range.map do |c|
    [c, key]
  end
end.flatten(1).to_h

end
