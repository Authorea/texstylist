require 'texstylist/csl_adaptor'
class Citations

  # Taken from our Authorea TeX server - texlive 2015 and custom journal styles.
  @@citation_styles_bst = Set.new(["ACM-Reference-Format-Journals", "AISB2008", "CUEDbiblio", "ChemCommun", "ChemEurJ",
  "Chicago", "IEEEtran", "IEEEtranM", "IEEEtranMN", "IEEEtranN", "IEEEtranS", "IEEEtranSA", "IEEEtranSN", "InorgChem",
  "JAmChemSoc", "JAmChemSoc_all", "JHEP", "LHCb", "PhDbiblio-bold", "PhDbiblio-case", "PhDbiblio-url", "PhDbiblio-
  url2", "Science", "ScienceAdvances", "UNAMThesis", "aa", "aaai", "aaai-named", "aabbrv", "aalpha", "abbrv", "abbrv-
  fr", "abbrv-letters", "abbrvcnb", "abbrvdin", "abbrvhtml", "abbrvnat", "abbrvnat-fr", "abbrvurl", "abntex2-alf",
  "abntex2-num", "abstract", "achemso", "achicago", "acl", "acm", "acm-fa", "acm-sigchi", "acmtrans-ims", "address",
  "address-html", "address-ldif", "address-vcard", "adfathesis", "adrbirthday", "adrconv", "adrfax", "aer", "aertt",
  "agecon", "agsm", "agu", "agu04", "agu08", "agufull", "agufull04", "agufull08", "aiaa", "aichej", "aipauth4-1",
  "aipnum4-1", "aj", "ajae", "ajl", "alpha", "alpha-fr", "alpha-letters", "alphadin", "alphahtml", "alphahtmldate",
  "alphahtmldater", "alphaurl", "ametsoc", "ametsoc2014", "ams-alph", "ams-pln", "amsalpha", "amsplain", "amsra",
  "amsrn", "amsrs", "amsru", "amsry", "angew", "annotate", "annotation", "anotit", "aomalpha", "aomplain", "apa",
  "apacann", "apacannx", "apacite", "apacitex", "apalike", "apalike-fr", "apalike-letters", "apalike2", "apanat1b",
  "apecon", "apj", "aplain", "apsr", "apsrev", "apsrev4-1", "apsrevM", "apsrmp", "apsrmp4-1", "apsrmpM", "asa-fa",
  "asaetr", "ascelike", "asp2010", "astron", "atlasBibStyleWithTitle", "atlasBibStyleWoTitle", "aunsnot", "aunsrt",
  "authordate1", "authordate2", "authordate3", "authordate4", "bababbr3", "bababbr3-fl", "bababbr3-lf", "bababbrv",
  "bababbrv-fl", "bababbrv-lf", "babalpha", "babalpha-fl", "babalpha-lf", "babamspl", "babplai3", "babplai3-fl",
  "babplai3-lf", "babplain", "babplain-fl", "babplain-lf", "babunsrt", "babunsrt-fl", "babunsrt-lf", "bbs",
  "besjournals", "bestpapers", "bestpapers-export", "bgteuabbr", "bgteuabbr2", "bgteupln", "bgteupln2", "bgteupln3",
  "biblatex", "bibtoref", "biochem", "birthday", "bmc-mathphys", "bookdb", "cascadilla", "cbe", "cc", "cc2", "cell",
  "chetref", "chicago", "chicago-annote", "chicago-fa", "chicagoa", "chronological", "chronoplainnm", "chscite",
  "cje", "cmpj", "cont-ab", "cont-au", "cont-no", "cont-ti", "copernicus", "cv", "databib", "dcbib", "dcu", "dinat",
  "dk-abbrv", "dk-alpha", "dk-apali", "dk-plain", "dk-unsrt", "dlfltxbbibtex", "dtk", "easy", "ecca", "ecta",
  "elsarticle-harv", "elsarticle-num", "elsarticle-num-names", "email", "email-html", "en-mtc", "erae", "expcites",
  "expkeys", "export", "fbs", "fcavtex", "figbib", "figbib1", "finplain", "fr-mtc", "francais", "francaissc",
  "frontiersinMED", "frontiersinMED&FPHY", "frontiersinSCNS&ENG", "frplainnat-letters", "gatech-thesis", "gatech-
  thesis-losa", "genetics", "gerabbrv", "geralpha", "gerapali", "gerplain", "gerunsrt", "gji", "glsplain", "glsshort",
  "gost2003", "gost2003s", "gost2008", "gost2008l", "gost2008ls", "gost2008n", "gost2008ns", "gost2008s", "gost705",
  "gost705s", "gost780", "gost780s", "h-physrev", "hc-de", "hc-en", "humanbio", "humannat", "iclr2015", "ieeepes",
  "ieeetr", "ieeetr-fa", "ieeetr-fr", "ier", "ifacconf", "ifacconf-harvard", "ijmart", "ijqc", "imac", "imsart-
  nameyear", "imsart-number", "inlinebib", "iopart-num", "is-abbrv", "is-alpha", "is-plain", "is-unsrt", "itaxpf",
  "iucr", "jabbrv", "jae", "jalpha", "jas99", "jbact", "jcc", "jfm", "jipsj", "jmb", "jmr", "jname", "jneurosci",
  "jorsj", "jox", "jpc", "jpe", "jphysicsB", "jplain", "jponew", "jss2", "jtb", "jthcarsu", "junsrt", "jurabib",
  "jurarsp", "jureco", "jurunsrt", "jxb", "klunamed", "klunum", "kluwer", "ksfh_nat", "letter", "listbib", "ltugbib",
  "mbplain", "mbunsrtdin", "mdpi", "mn2e", "mnras", "mslapa", "munich", "mybibstyle", "named", "namunsrt", "nar",
  "natbib", "natdin", "naturemag", "nddiss2e", "nederlands", "newapa", "newapave", "oega", "ol", "opcit", "osajnl",
  "papalike", "pccp", "perception", "phaip", "phapalik", "phcpc", "phiaea", "phjcp", "phnf", "phnflet", "phone",
  "phpf", "phppcf", "phreport", "phrmp", "plabbrv", "plain", "plain-fa", "plain-fa-inLTR", "plain-fa-inLTR-beamer",
  "plain-fr", "plain-letters", "plainDemo", "plaindin", "plainhtml", "plainhtmldate", "plainhtmldater", "plainnat",
  "plainnat-fa", "plainnat-fr", "plainnat-letters", "plainnm", "plainurl", "plainyr", "plalpha", "plos2009",
  "plos2015", "plplain", "plunsrt", "pnas", "pnas2009", "psuthesis", "refer", "regstud", "resphilosophica",
  "revcompchem", "rsc", "rusnat", "sageep", "sapthesis", "savetrees", "seg", "seuthesis", "siam", "siam-fr", "siam-
  letters", "spbasic", "spiebib", "spiejour", "splncs03", "spmpsci", "spphys", "sweabbrv", "swealpha", "sweplain",
  "sweplnat", "sweunsrt", "tandfx", "tex-live", "texsis", "thesnumb", "thubib", "tieice", "tipsj", "trb", "tufte",
  "udesoftec", "uestcthesis", "ugost2003", "ugost2003s", "ugost2008", "ugost2008l", "ugost2008ls", "ugost2008n",
  "ugost2008ns", "ugost2008s", "unified", "unsrt", "unsrt-fa", "unsrt-fr", "unsrtabbrv3", "unsrtdin", "unsrthtml",
  "unsrtnat", "unsrtnat-fr", "unsrtnm", "unsrturl", "upmplainnat", "usmeg-a", "usmeg-n", "ussagus", "utphys", "vak",
  "vancouver", "worlddev", "xagsm", "xplain", "zharticle"].map{|style| style.to_sym})

  @@citation_styles_csl = Set.new(CSLAdaptor.list)

  class << self
    attr_accessor :citation_styles_bst, :citation_styles_csl

    def stylize_citations(article, bibliography, export_style, citation_style, options = {})
      # nothing to do if no bibliography is given
      return article if bibliography.to_s.empty?

      # The citation style we'll use for this export run is either:
      citation_style = citation_style.to_s.to_sym
      if !(@@citation_styles_csl.member?(citation_style) || @@citation_styles_bst.member?(citation_style))
        # The citation style isn't recognized, use a default for the style - the default for the article would've been passed in
        citation_style = export_style.citation_style || # 1. Provided by the export style specification
                         :plain # 2. The plain citation style as an ultimate fallback
      end
      @bib_processor = if @@citation_styles_csl.member? citation_style
        :citeproc
      elsif @@citation_styles_bst.member? citation_style
        :bibtex
      else
        # Fallback to using citeproc processing, as it is faster and simpler
        :citeproc
      end

      # Bibtex requires some extra latex definitions:
      case @bib_processor
      when :bibtex
        article << "\n\n"
        article << "\\bibliographystyle{#{citation_style}}\n"
        # TODO: The dfgproposal treatment is needed for any template using BibLaTeX
        #       for typesetting bibliographies; this is a first of potentially many
        article << case export_style.symbol
        when :dfgproposal
          # The \\printbibliography needs to be in the Bibliography section, which is NOT
          #     at the end of the article. So we disable it entirely here.
          # article << "\\printbibliography\n\n"
          ""
        when :plos2015 # disable line numbers for PLOS bibliographies
          "\\nolinenumbers\n\\bibliography{#{bibliography}}\n\n"
        else
          "\\bibliography{#{bibliography}}\n\n"
        end
      when :citeproc
        bibtex = begin
          BibTeX.open(bibliography)
        rescue => e
          # TODO: Return errors, without fully failing
          puts "Failed to fill in citations due to errors in your Bibliography #{bibliography}: #{e}"
          nil
        end
        # Pandoc can't handle \hyperref links, so don't decorate for the word export.
        article = CSLAdaptor.replace_citations_with_csl(article, citation_style, bibtex, decorate: options["decorate"])
      end

      return article
    end

  end
end