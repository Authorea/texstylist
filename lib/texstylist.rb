require 'texstyles'
class Texstylist
  attr_accessor :style
  @@default_package_candidates = %w(graphicx grffile latexsym textcomp longtable multirow booktabs)
  @@default_package_options = {'grffile' => ['space']}

  def initialize(style = :authorea, package_candidates = @@default_package_candidates)
    @style = Texstyles::Style.new(style)
    # setup default packages
    @default_packages_list = package_candidates.select{|candidate| @style.package_compatible?(candidate)}
  end

  def render(article_body, article_metadata = {})
    return '' if article_body.empty?
    @default_packages = ''
    @default_packages_list.each do |package|
      @default_packages << if options = @@default_package_options[package]
        "\\usepackage[#{options.join(',')}]{#{package}}\n"
      else
        "\\usepackage{#{package}}\n"
      end
    end
    @default_packages << "\n"

    article_metadata[:default_packages] = @default_packages
    preamble = @style.render_latex(article_metadata)

    full_article = preamble + "\n\n" + article_body

    full_article << "\n\\end{document}" if @style.package_compatible?(:latex) # finalize latex documents
    full_article << "\n\n"
    return full_article
  end

end