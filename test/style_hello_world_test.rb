require 'helper'
require 'texstylist'

class StyleHelloWorldTest < Minitest::Test

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

  def test_can_load_metadata
  end

  def test_can_style_hello_world_with_metadata
    stylist = Texstylist.new(:article)

    article_body = 'Hello \world!'
    article_metadata = {
      header: '\def\world{World}',
      long_title: 'A Hello Article',
      first_author: 'Hello Author',
      first_affiliation: 'Texstylist Gem',
      coauthor_list: ['Author 2'],
      coauthor_affiliations: ['Another Gem']
    }

    styled_article_body = stylist.render(article_body, article_metadata)

    assert styled_article_body.include?(article_body), 'content was passed in'
    assert styled_article_body.match(/\\usepackage\{graphicx\}/), 'default graphicx package is on'
    assert styled_article_body.match(/\\begin\{document\}/), 'document start exists'
    assert styled_article_body.match(/\\end\{document\}/), 'document end exists'

  end
end
