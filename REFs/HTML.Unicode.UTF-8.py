#!/usr/bin/python
# HTML UTF-8  https://www.w3schools.com/charsets/ref_html_utf8.asp
  # Unicode is a character-set; UTF-8 is an encoding.
  # Charsets translate characters to integers;  char =>  int  [glyph to CODE-POINTS]
  # Encodings translate integers to binary;     int  =>  bin  [CODE-POINTS to bytes]
    # `.encode()` TO bytes; HEXIDECIMAL ESCAPE SEQUENCES
    # `.decode()` TO Unicode; UNICODE ESCAPE SEQUENCES [which confusingly use hex!]
    '\x41\x42\x43'        # 'ABC'; encoded to HEXIDECIMAL ESCAPE SEQUENCE
    '\u0041\u0042\u0043'  # 'ABC'; decoded to UNICODE ESCAPE SEQUENCE
    print  '\x41\x42\x43'        # => ABC
    print  "\u0041\u0042\u0043"  # => \u0041\u0042\u0043
    print u"\u0041\u0042\u0043"  # => ABC

    # Unicode Charset   https://en.wikipedia.org/wiki/Unicode [CODE-POINTS]
    # UTF-8   Encoding  https://en.wikipedia.org/wiki/UTF-8   [bytes (1-4)]
    # [UTF: "Unicode Transformation Format"]
    # [UTF-8 is *the* universally accepted encoding for all Unicode Charsets.]

    # Code Point [integer repr' 1 char of a charset, typically rep'd in hex]
      # ASCII:                128 code points x00 - x7F
      # Extended ASCII        256 code points x00 - xFF
      # Unicode         1,114,112 code points x00 - x10FFFF
       # 17 planes (1 basic multilingual, + 16 supplementary), each w/ 65,536 (2^16) code points.

    import unicodedata as u               # access to Unicode Character Database (UCD)
      u.category(u'a')                    # => 'Ll'  # L:letter, l:lowercase
      u.name(u'a')                        # => 'LATIN SMALL LETTER A'
      print u'\u00ae',u.name(u'\u00ae')   # => ® REGISTERED SIGN    
      print u'\xd0',u.name(u'\xd0')       # => Ð LATIN CAPITAL LETTER ETH
      u.lookup('BLACK SPADE SUIT')        # => u'\u2660'
      print u.lookup('BLACK SPADE SUIT')  # => ♠
    
    # `\u2627` is the Unicode Code Point for CHI RHO, in hexidecimal representation 
    str = u'foo bar \u2627'    # => u'foo bar \u2627'
    str = str.encode('utf-8')  # => 'foo bar \xe2\x98\xa7'
    print str                  # => foo bar ☧
    str = str.decode('utf-8')  # => u'foo bar \u2627'
    
    # 'xmlcharrefreplace' [Unicode to HTML ENTITY]
    str = str.encode('ascii','xmlcharrefreplace')  # => 'foo bar &#9767;'
    str = str.decode('ascii','xmlcharrefreplace')  # => u'foo bar &#9767;'
    
    # 'ignore' [removes what can't be decoded] 
    str = u'foo bar \u9999'
    str = str.encode('utf-8','ignore')    # => 'foo bar '
    
    str = u'foo bar \u9999'
    str = str.encode('utf-8')           # => 'foo bar \xe9\xa6\x99'
    str = str.decode('ascii','ignore')  # => u'foo bar '

  print "fo,o';bar:ok!"     # => fo,o';bar:ok!
  print 'c:\zoo\\bar'       # => c:\zoo\bar    [escaped]
  print r'c:\zoo\\bar'      # => c:\zoo\\bar   [raw]
  print u'c:\zoo\u005cbar'  # => c:\zoo\bar    [Unicode]

  # UTF-8; Unicode [Latin Suplemental]  
  print u'\u00d8\t&Oslash;' # => Ø       &Oslash;
  print u'\u00b5\t&micro;'  # => µ       &micro;
  print u'\u00a9\t&copy;'   # => ©       &copy;
  # UTF-8; Unicode [Greek and Coptic]
  print u'\u03a9\t&Omega;'  # => Ω       &Omega;
  print u'\u03b2\t&beta;'   # => β       &beta;
  print u'\u03bc\t&mu;'     # => μ       &mu;
  print u'\u03c1\t&rho;'    # => ρ       &rho;
  print u'\u03c7\t&chi;'    # => χ       &chi;
  print u'\u03c9\t&omega;'  # => ω       &omega;
  # UTF-8; Unicode [Letterlike Symbols]
  print u'\u2014\t&mdash;'  # => —       &mdash;
  print u'\u2022\t&bull;'   # => •       &bull;
  print u'\u2020\t&dagger;' # => †       &dagger;
  print u'\u2026\t&hellip;' # => …       &hellip;
  print u'\u2116'           # => №       NUMERO SIGN
  # UTF-8; Unicode [Geometric Shapes]
  print u'\u25cf' # => ●       BLACK CIRCLE
  # UTF-8; Unicode [Misc Symbols]
  print u'\u2626' # => ☦       ORTHODOX CROSS
  print u'\u2627' # => ☧       CHI RHO
  print u'\u2628' # => ☨       CROSS OF LORRAINE
  print u'\u2629' # => ☩       CROSS OFJERUSALEM
  print u'\u262d' # => ☭       HAMMER AND SICKLE
  print u'\u262a' # => ☪       STAR AND CRESCENT
  print u'\u2622' # => ☢       RADIOACTIVE SIGN
  print u'\u2623' # => ☣       BIOHAZARD SIGN
  # UTF-8; Unicode [Dingbats]
  print u'\u271d' # => ✝       LATIN CROSS
  print u'\u271e' # => ✞       SHADOWED LATIN CROSS
  print u'\u2721' # => ✡       STAR OF DAVID
  print u'\u275d' # => ❝        HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT
  print u'\u275e' # => ❞        HEAVY DOUBLE COMMA QUOTATION MARK ORNAMENT
  print u'\u2764' # => ❤       HEAVY BLACK HEART
  print u'\u278a' # => ➊       DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ONE
