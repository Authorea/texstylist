# Motivation for this adaptor can be seen at: https://github.com/inukshuk/csl-ruby/issues/6
require 'citeproc/ruby'
require 'csl/styles'
require 'bibtex'
require 'texstylist/csl_constants'
require 'texstylist/latex_util'

class CSLAdaptor

  # Borrowing from https://github.com/inukshuk/jekyll-scholar/blob/master/lib/jekyll/scholar/utilities.rb#L5
  # until CSL features stabilize
  #
  # Load styles into static memory.
  # They should be thread safe as long as they are
  # treated as being read-only.
  STYLES = Hash.new do |h, k|
    style = CSL::Style.load k
    style = style.independent_parent unless style.independent?
    h[k.to_s] = style
  end

  def self.list
    Dir.glob(File.join(CSL::Style.root,'**','*.csl')).map{|p| File.basename(p,".*").to_sym}
  end

  def self.safe_style(style)
    if style.is_a? Symbol
      style = style.to_s
    end
    style_path = File.basename(style,".*") + '.csl'
    expected_path = File.join(CSL::Style.root,style_path)
    dependent_path = File.join(CSL::Style.root,'dependent',style_path)
    if File.exist?(expected_path)
      style
    elsif File.exist?(dependent_path)
      # While waiting for the main CSL library to implement dependent support, we'll pass the parent here
      begin
        dom = Nokogiri::XML(File.open(dependent_path))
        parent_link = dom.search('link[@rel="independent-parent"]').first.attr('href')
        parent_style = parent_link.sub('http://www.zotero.org/styles/','')
      rescue
        :'chicago-author-date'
      end
    else
      :'chicago-author-date'
    end
  end

  def self.load(style)
    style = safe_style(style)
    begin
      style.present? && CSL::Style.load(style)
    rescue
      nil
    end
  end

  def self.citation_style_names
    CSLConstants.citation_style_names
  end
  def self.citation_style_symbols
    HashWithIndifferentAccess.new(self.citation_style_names.invert)
  end

  def self.replace_citations_with_csl(text, citation_style, bibtex, options={})
    options = {decorate: true}.merge(options)
    citation_style = CSLAdaptor.safe_style(citation_style)
    renderer = CiteProc::Ruby::Renderer.new(format: 'text', style: citation_style)
    # Dependent styles still experience issues, use the default chicago processor as a fallback
    default_renderer = CiteProc::Ruby::Renderer.new(format: 'text', style: :'chicago-author-date')

    csl_unique_count = 0
    csl_map = {}
    latex_util = LatexUtil.new
    references_section = "\\section*{References}\n"
    text = latex_util.preprocess_verb(text)
    text = text.gsub(LatexUtil.citation_regex) do |match|
      cite_type = $~[:type]
      star   = $~[:star]
      optional_arg1 = $~[:opt1]
      optional_arg2 = $~[:opt2]
      braces = $~[:braces]

      citations = braces.split(',').flatten
      citations = citations.map {|c| c.strip}
      length = citations.length
      csl_text = citations.map do |c|
        new_unique = !csl_map[c]
        if new_unique
          csl_unique_count += 1
          csl_map[c] = csl_unique_count
        end
        csl_index = csl_map[c]

        bib_data = !c.empty? && bibtex && bibtex[c.to_sym]
        if bib_data.nil? # fallback - no such bib entry
          '(missing citation)'
        else
          item = CiteProc::CitationItem.new id: c do |ci|
            ci.data = CiteProc::Item.new bib_data.to_citeproc
            # numeric styles not yet implemented in citeproc-ruby, so we need to manually set the number, see:
            # https://github.com/inukshuk/citeproc-ruby/issues/40
            ci.data[:'citation-number'] = csl_index
          end
          # I. If just added citation, add it to final Bibliography
          if new_unique
            begin # sometimes the CSL style has no bibliography definition, and the references render raises exceptions
              rendered_reference = renderer.render item, STYLES[citation_style].bibliography
              if options[:decorate]
                references_section << "\\phantomsection\n\\label{csl:#{csl_unique_count}}"
              end
              references_section << rendered_reference
              references_section << "\n\n"
            rescue => e
              puts "CSL bibliography render failed with: ", e
            end
          end

          # II. Always add the inline rendered citation
          begin
            inline_render = renderer.render [item], STYLES[citation_style].citation
            if inline_render.blank?
              inline_render = begin
                default_renderer.render [item], STYLES[citation_style].citation
              end
              if inline_render.blank?
                inline_render = '(missing citation)'
              end
            end
            if options[:decorate]
              "\\hyperref[csl:#{csl_index}]{#{inline_render}}"
            else
              inline_render
            end
          rescue => e
            puts "CSL citation render failed with: ", e
            ""
          end
        end
      end
      csl_text.join(" ")
    end
    return latex_util.postprocess_verb(text) + "\n\n" + references_section
  end


end
