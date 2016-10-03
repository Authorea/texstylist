# TeX Stylist

[Authorea](http://www.authorea.com)'s TeX-based stylist. Think Instagram filters for scholarly documents.

**CAUTION: This repository is in a pre-alpha dev sprint, consider it completely unstable until a 0.1.0 release**

[![Build Status](https://secure.travis-ci.org/Authorea/texstylist.png?branch=master)](https://travis-ci.org/Authorea/texstylist)
[![license](http://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/authorea/texstylist/master/LICENSE)
[![Gem Version](https://badge.fury.io/rb/texstylist.svg)](https://badge.fury.io/rb/texstylist)

## Common Questions

**Who is this gem intended for?** Mostly for people working on micro-publication platforms interested in a turnkey solution to customizing the appearance of exported documents. If you're an author you can simply, and freely, use the export features of [Authorea](https://www.authorea.com).

**Can I directly use it on my LaTeX documents?** Almost. As convention has it with Authorea, you can use your document body directly, but we request that you prepare the document metadata separately, together with the customization parameters.

We have also released the [texstyles](https://github.com/Authorea/texstyles) Ruby gem, which contains the full list of scholarly styles used at Authorea. We welcome contributions and corrections!


## Usage

```ruby
require 'texstylist'

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

# Any available Style from the texstyles gem is accepted
stylist = Texstylist.new(:authorea)
# A single render call styles the document and citations, typesets the metadata, and handles internationalization
styled_doc = stylist.render(body, header, metadata)

# Enjoy!
```

You can see a full example [here](https://github.com/Authorea/texstylist/blob/master/example/example_stylize.rb).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'texstylist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install texstylist

## Roadmap

### Supported via [Texstyles](https://github.com/Authorea/texstyles)
 * 100+ and growing scholarly export styles
 * Core metadata items of scholarly articles
 * White/blacklisting LaTeX style and class conflicts
 * Independent citation style specifications

### Support via [Texstylist](https://github.com/Authorea/texstylist)
 * Unicode-only input and output
 * Automatic internationalization for LaTeX via babel and pdflatex, by analyzing Unicode locales
 * Citation styling API, supporting both [CSL](http://citationstyles.org/) and [bibtex](http://www.bibtex.org/) style files (.bst)

### Upcoming
 * Use a standard vocabulary and serialization format(s) for scholarly metadata
 * Undergo a round of community feedback and evolve the gem respectively

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).