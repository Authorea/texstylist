require 'helper'
require 'texstylist'

class StyleHelloWorldTest < Minitest::Test
  def setup
    @example_metadata = YAML.load(File.read(File.join('test','fixtures','example_scholarly_article.yml')))
    @example_body = File.read(File.join('test','fixtures','example_body.tex'))
    @example_bibliography = File.join('test','fixtures','example_bibliography.bib')
  end

  def test_can_load_style
    stylist = Texstylist.new(:authorea)
    style = stylist.style
    assert_equal Texstyles::Style, style.class, 'successfully loaded style'
    assert_equal "Authorea", style.name, 'successfully loaded style spec'
  end

  def test_can_style_hello_world
    stylist = Texstylist.new(:authorea)

    latex = 'Hello World!'
    styled_latex = stylist.render(latex)

    assert styled_latex.include?(latex), 'content was passed in'
    assert styled_latex.match(/\\usepackage\{graphicx\}/), 'default graphicx package is on'
    assert styled_latex.match(/\\begin\{document\}/), 'document start exists'
    assert styled_latex.match(/\\end\{document\}/), 'document end exists'
  end

  def test_can_style_hello_world_with_metadata
    stylist = Texstylist.new(:article)

    body = 'Hello \world!'
    header = '\def\world{World}'

    styled_doc = stylist.render(body, header, @example_metadata)

    assert styled_doc.include?(body), 'content was passed in'
    assert styled_doc.match(/\\usepackage\{graphicx\}/), 'default graphicx package is on'
    assert styled_doc.match(/\\begin\{document\}/), 'document start exists'
    assert styled_doc.match(/\\end\{document\}/), 'document end exists'
  end

  def test_can_auto_internationalize_cyrillic
    stylist = Texstylist.new(:article)

    body = 'Hello \world! Здравей свят! Done.'
    header = '\def\world{World}'

    styled_doc = stylist.render(body, header, @example_metadata)

    assert styled_doc.include?('Здравей свят'), 'cyrillic passed as is'
    assert styled_doc.include?('\\usepackage[russian,english]{babel}')
    assert styled_doc.include?('\\selectlanguage{russian}'), 'cyrillic activated'
    assert styled_doc.include?('\\selectlanguage{english}'), 'english activated'
  end

  def test_can_style_citations_with_csl
    metadata = @example_metadata.dup
    metadata["bibliography"] = @example_bibliography

    stylist = Texstylist.new(:article)
    styled_doc = stylist.render(@example_body, @example_header, metadata)

    assert styled_doc.match(/\(Author 2016\)/), 'inline citations work'
    assert styled_doc.match(/\\section\*\{References\}/), 'references section was created'
    assert styled_doc.match(/Author, The\. 2016\./), 'references entry has valid author'
    assert styled_doc.match(/“The Title of the Work\.”/), 'references entry has valid title'
  end

  def test_can_style_citations_with_bibtex
    metadata = @example_metadata.dup
    metadata["bibliography"] = @example_bibliography
    metadata["citation_style"] = "apacite" # simply pick a bibtex citation style

    stylist = Texstylist.new(:article)
    styled_doc = stylist.render(@example_body, @example_header, metadata)

    assert styled_doc.match(/\\cite\{example\}/), 'inline citations left as-is'
    assert styled_doc.match(/\\bibliographystyle\{apacite\}/), 'citation style was activated'
    assert styled_doc.match(/\\bibliography\{[^}]+example_bibliography\.bib\}/), 'bibliography inclusion was added'
  end

  def test_readme_example
    header = '% A latex preamble, of e.g. custom macro definitions, or custom overrides for the desired style'
    abstract = 'An (optional) document abstract'
    body = 'An example article body.'

    metadata = {
      'title' => 'An example scholarly article',
      'abstract' => abstract,
      # ... full range of scholarly metadata omitted for space
      'bibliography' => 'biblio.bib',
      # any bibtex or CSL citation style is accepted
      'citation_style' => 'apacite',
    }

    stylist = Texstylist.new(:authorea) # any style from the texstylist gem is accepted
    styled_doc = stylist.render(body, header, metadata)
  end
end
