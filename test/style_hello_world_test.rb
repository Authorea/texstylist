require 'helper'
require 'texstylist'

class StyleHelloWorldTest < Minitest::Test
  def setup
    @example_metadata = YAML.load(File.read(File.join('test','fixtures','example_scholarly_article.yml')))
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

    styled_body = stylist.render(body, header, @example_metadata)

    assert styled_body.include?(body), 'content was passed in'
    assert styled_body.match(/\\usepackage\{graphicx\}/), 'default graphicx package is on'
    assert styled_body.match(/\\begin\{document\}/), 'document start exists'
    assert styled_body.match(/\\end\{document\}/), 'document end exists'
  end

  def test_can_auto_internationalize_cyrillic
    stylist = Texstylist.new(:article)

    body = 'Hello \world! Здравей свят! Done.'
    header = '\def\world{World}'

    styled_body = stylist.render(body, header, @example_metadata)

    assert styled_body.include?('Здравей свят'), 'cyrillic passed as is'
    assert styled_body.include?('\\usepackage[russian,english]{babel}')
    assert styled_body.include?('\\selectlanguage{russian}'), 'cyrillic activated'
    assert styled_body.include?('\\selectlanguage{english}'), 'english activated'
  end
end
