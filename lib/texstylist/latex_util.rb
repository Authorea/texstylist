class LatexUtil
  @inner_chars = "[\\p{word},\\w,\\d,\\-,:,\\.,\\/,%,&,;,\(,\),\\* ]"
  @optional_args_chars = "[\\p{word},\\w,\\d,\\-,:,\\.,\\/,%,&,;,\(,\),!,@,\\#,$,\\^,\\*,\\(,\\),<,>,/,\\|,=,_,\\- ]"
  @citation_regex = /[\/,\\](?<no>no)?cite(?<type>p|t|al[tp]|NP)?(?<star>\*)?(\[(?<opt1>#{@optional_args_chars}*)\](\[(?<opt2>#{@optional_args_chars}*)\])?)?\{(?<braces>#{@inner_chars}+)\}/

  class << self
    attr_accessor :citation_regex
  end

  def initialize
    @verb_store = {}
  end

  def preprocess_verb(text)
    @verb_store = {}
    verb_index = 'a'
    # 1. Escape source \verb
    text = text.gsub(/\\verb(.)((?:(?!\1).)*)\1/m) do |match|
      verb_index << 'a'
      key = "aureplacedverb#{verb_index} "
      @verb_store[verb_index] = $2
      key
    end

    # 2. Escape source \begin{verbatim}
    text = text.gsub(/\\begin\{verbatim\}(.*?)\\end\{verbatim\}/m) do |match|
      verb_index << 'a'
      key = "aureplacedverb#{verb_index} "
      @verb_store[verb_index] = $1
      key
    end

    # 3. Escape rendered \verb (as <code> elements)
    text = text.gsub(/\<code\>(.*?)\<\/code\>/m) do |match|
      verb_index << 'a'
      key = "aureplacedverb#{verb_index} "
      @verb_store[verb_index] = $1
      key
    end

    return text
  end

  def postprocess_verb(text)
    return text if @verb_store.empty?
    text.gsub(/aureplacedverb(\w+)/) do |match|
      "\\verb|"+@verb_store[$1]+"|"
    end
  end

end