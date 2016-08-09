require 'helper'
require 'unicode_babel'

class UnicodeBabelTest < Minitest::Test

  def test_correct_latex_inclusions_for_various_Unicode_locales
    latex_string = UnicodeBabel.latex_inclusions("testing проба here")
    assert_equal "\\usepackage[T2A]{fontenc}\n\\usepackage[russian,english]{babel}\n", latex_string, "correct inclusions for Bulgarian"

    latex_string = UnicodeBabel.latex_inclusions("who is Henri Poincaré ?")
    assert_equal "\\usepackage[ngerman,english]{babel}\n", latex_string, "correct inclusions for diacritics"
  end

  def test_no_op_on_regular_latex
    example = "\\def\\example{\\textbf{macro}}\n \\section{Foo}\n This is an \\textit{\\example} macro.\n"
    example_processed = UnicodeBabel.activate_foreign_languages(example)
    assert_equal example, example_processed, "No-op on regular latex"
  end

  def test_can_handle_unbalanced_latex
    example = "\\def\\example{\\textbf{macro}}\n \\section{Foo}\n This is } an \\textit{\\example} macro.\n"
    example_processed = UnicodeBabel.activate_foreign_languages(example)
    assert_equal example, example_processed, "No-op on regular unbalanced latex"
  end

  def test_can_handle_caption_macros
    example = 'testing \caption{проба тук} end.'
    example_processed = UnicodeBabel.activate_foreign_languages(example)
    result_expected = "testing \\caption{\\selectlanguage{russian}{проба тук}\\selectlanguage{russian}} \\selectlanguage{english}end."
    assert_equal result_expected, example_processed, "can handle captions"
  end

  def test_can_handle_complex_macros
    example = 'testing \macro   [ optional stuff ]{many}{mandatory}{arguments}{проба тук} end.'
    example_processed = UnicodeBabel.activate_foreign_languages(example)
    result_expected = "testing \\selectlanguage{russian}\\macro   [ optional stuff ]{many}{mandatory}{arguments}{проба тук}\\selectlanguage{russian} \\selectlanguage{english}end."
    assert_equal result_expected, example_processed, "can handle complex macros"
  end

  def test_no_op_on_english_math
    example = '\mathbf{F}_{S-S}(\mathbf{d})&=&\exp\left\{\frac{a_1d^2+a_2d+a_3}{d+a_4}\right\}\mathbf{\hat{d}}\label{eq:interparticle}'
    example_processed = UnicodeBabel.activate_foreign_languages(example)
    assert_equal example, example_processed, "No-op on english math"
  end

end
