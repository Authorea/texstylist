require 'texstylist'

header = '% A latex preamble, of e.g. custom macro definitions, or custom overrides for the desired style'
abstract = 'An (optional) document abstract'
body = 'An example article body.'

metadata = {
  'title' => 'An example scholarly article',
  'short_title' => 'Example article',
  'authors' => [
  { 'name' => 'First Author',
    'affiliation' => 1},
  { 'name' => 'Second Author',
    'affiliation' => 2},
  { 'name' => 'Third Author',
    'affiliations' => [1, 2]}
  ],
  'affiliations' => {
    1 => 'Example Organization',
    2 => 'Another Organization'
  },
  'abstract' => abstract
}


# Choose any available Texstyles::Style here
stylist = Texstylist.new(:authorea)

# A single render call styles the document and citations, typesets the metadata, and handles internationalization
stylized_document = stylist.render(body, header, metadata)

# Enjoy!
puts stylized_document