require 'texstyles'
class Texstylist
  attr_accessor :style
  @@default_package_candidates = %w(
    graphicx grffile latexsym textcomp longtable multirow booktabs ams natbib url hyperref latexml
    inputenc babel)
  @@default_package_options = {'grffile' => ['space'], 'inputenc' => ['utf8']}

  def initialize(style = :authorea, package_candidates = @@default_package_candidates)
    @style = Texstyles::Style.new(style)
    # setup default packages
    @default_packages_list = package_candidates.select{|candidate| @style.package_compatible?(candidate)}
  end

  def render(body, header=nil, metadata = {})
    return '' if body.empty?
    @header = header

    # I. Prepare default package inclusions
    @default_packages = ''
    @default_packages_list.each do |package|
      next if @header && @header.match(/\{(?:#{package})\}/) # skip if overridden by the header.
      options = @@default_package_options[package]
      setup_macro = nil

      # I.1. Expand common aliases, prepare extra setup steps
      case package
      when 'ams' # alias for a family of packages
        package = 'amsfonts,amsmath,amssymb'
      when 'hyperref'
        setup_macro = "\\hypersetup{colorlinks=false,pdfborder={0 0 0}}"
      when 'latexml'
        package = nil
        setup_macro = "\% You can conditionalize code for latexml or normal latex using this.\n"+
                      "\\newif\\iflatexml\\latexmlfalse"
      when 'babel'
        # handle globally, as we need to automagically internationalize any Unicode
        package = nil
      end

      # I.2. Add the package inclusion, if any
      if package
        @default_packages << if options
          "\\usepackage[#{options.join(',')}]{#{package}}"
        else
          "\\usepackage{#{package}}"
        end
        @default_packages << "\n"
      end
      # I.3 Add the setup macro, if any
      if setup_macro
        @default_packages << setup_macro + "\n"
      end
    end

    # II. Special graceful degradation treatment for common sources of conflicts, done once globally
    if !@style.package_compatible?(:natbib)
      @default_packages << "\n\\newcommand\\citet{\\cite}\n\\newcommand\\citep{\\cite}"
    end


    # III. Advanced auto-magical internationalization of unicode with babel (intended for use with pdflatex)
    if @style.package_compatible?(:babel)
      # Having the full body and preamble, figure out which flavours of babel we need (and potentially other text-dependent logic)
      metadata["default_packages"] = @default_packages
      preamble = @style.render_latex(metadata)
      # We'll have to rerender the preamble with all language locales setup
      @default_packages << UnicodeBabel::latex_inclusions(preamble + body)
      @default_packages << "\n"
      # And auto-deposit various language activation macros in the article itself
      body = UnicodeBabel::activate_foreign_languages(body)
    end

    # IV. Render the preamble and prepare the final latex document
    metadata["default_packages"] = @default_packages
    preamble = @style.render_latex(metadata)
    full_article = preamble + "\n\n" + body

    # IV.1. Normalize to simpler latex
    full_article = simplify_latex(full_article)
    # IV.2. Wrap up
    full_article << "\n\\end{document}" if @style.package_compatible?(:latex) # finalize latex documents
    full_article << "\n\n"

    return full_article
  end

  def simplify_latex(text)
    # \amp can be written as simply \&
    text = text.gsub(/\\amp([^\w])/, "\\\\&\\1")
    # simplify new line markup if needed
    text = text.gsub(/\r\n/, "\n")
  end

end