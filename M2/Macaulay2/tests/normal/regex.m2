-- tests for regex
assert(regex("^(.*[^ ])? *$", " abcdef ") === {(0, 8), (0, 7)})
assert(regex("^ *([^ ].*[^ ])? *$", " abcdef ") === {(0, 8), (1, 6)})
assert(regex("^ *([^ ].*)$", " abcdef ") === {(0, 8), (1, 7)})
assert(regex(".?", "") === {(0, 0)})
assert(regex(".*/", "/aa/bb") === {(0, 4)})
assert(regex("a|b", "a") === {(0,1)})
assert(regex("^a+$", " \naaa\n ") === {(2,3)})
assert(regex("$a"," $a") === null)
assert(regex(".*", "a\nb") === {(0, 1)})
assert(regex("a+", " aaa ") === {(1,3)})
assert(regex("a+", 0, " aaa ") === {(1,3)})
assert(regex("a+", 0, 0, " aaa ") === null)
assert(regex("a+", 0, 1, " aaa ") === {(1,3)})
assert(regex("a+", 0, 100, " aaa ") === {(1,3)})

-- tests for replace
s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
assert(replace("(A|B|C)", "\\L$1", s) === "abcdefghijklmnopqrstuvwxyzabcDEFGHIJKLMNOPQRSTUVWXYZ")
assert(replace("(a|b|c)", "\\U$1", s) === "ABCdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
assert(replace("---", "DEF", replace("DEF", "---", s)) === s)
assert(replace("(B)", ///\\bar \1///, "ABC") === "A\\bar BC")
assert(replace("a(b+)(c+)", "\\2\\1", " abbcc abccc ") === " ccbb cccb ")
assert(replace("a(b+).(c+)", "\\2\\1", " abbcc ab\nccc ") === " cbb ab\nccc ")
assert(replace("a", "b", "-a-a-") === "-b-b-")
assert(replace("^a", "x", "a \na \naaa a") === "x \nx \nxaa a")

-- tests for separate
s = "A\nB\r\nC"
assert(separate s === {"A","B","C"})
assert(separate s === lines s)
assert(separate "\n\nA\n\nB\n\n" === {"","","A","","B","",""})
assert(separateRegexp("[,.;]", "A:B.C,D,E;F.") === {"A:B","C","D","E","F",""})
assert(separate("[,.;]", "A:B.C,D,E;F.", Flags => RegexPOSIX) === {"A:B","C","D","E","F",""})
assert(concatenate separate("[\t ]+", " A 	 B C   D	E  F     G", Flags => RegexPOSIX) === "ABCDEFG")
s = "algng xjfr kfjxse xhgfj xooi xwj kvexr anvi endj xkfi"
assert(concatenate separate(" x[A-Za-z]*", s, Flags => RegexPOSIX) === "algng kfjxse kvexr anvi endj")
assert(concatenate separate(" (x)[A-Za-z]*", 1, s, Flags => RegexPOSIX) === "algng jfr kfjxse hgfj ooi wj kvexr anvi endj kfi")
assert(demark_" " separate("[ \t]*\r?\n[ \t]*", " A\n\t  B  \r\n  \tC ", Flags=>RegexPerl) === " A B C ")
-- TODO: at some point deprecate support for this
assert(separate(".", "ABC.DEF") === {"ABC", "DEF"})

-- tests for select
assert(select("a+","aaa aaaa") === {"aaa","aaaa"})
assert(select("[[:alpha:]]+", "Dog, cat, and deer.") === {"Dog","cat","and","deer"})
assert(select("^.*$", "ABC\nDEF\r\nGHI") === {"ABC","DEF","GHI"})
assert(select("([a-zA-Z]+);", "$1", "Dog; cat, deer;") === {"Dog","deer"})
assert(select("([a-zA-Z]+);", "\\L$1", "Dog; cat, deer;") === {"dog","deer"})
s = "catfish cats dogs"
assert(select("cat(?!fish)", s, Flags => RegexPerl) === {"cat"})
assert(select("\\w+(?=s\\b)", s, Flags => RegexPerl) === {"cat", "dog"})
s = "goldfish swordfish catfish catdog"
assert(select("\\w+(?=fish)", s, Flags => RegexPerl) === {"gold","sword","cat"})
assert(select("(?<=cat)\\w+", s, Flags => RegexPerl) === {"fish","dog"})

-- tests for match
assert not match(".a",   "  \na  ")
assert     match("^a",   "  \na  ")
assert     match(".a",   "  a  ")
assert not match("^a",   "  a  ")
assert not match("a\\>", "ab")
assert not match("a\\b", "ab")
assert match("(a)",   "aa")
assert match("a+",    "aa")
assert match("a[2]",  "a2")
assert match("a[^a]", "a2")
assert match("a\\>",  "a b")
assert match("a\\>",  "a")
assert match("a\\b",  "a b")
assert match("a{2}",  "aa")
assert match("a|b",   "a b")
assert (lastMatch === {(0, 1)})
assert match({"Cat", "Dog"}, "CatDog")
assert match({"Cat", "Dog"}, "CatDog", Strategy => all)
assert match({"Cat", "Dog"}, "Catfish")
assert not match({"Cat", "Dog"}, "Catfish", Strategy => all)
assert not match("cats", "three dogs, two catfishes, and a cat")
assert     match("cat",  "three dogs, two catfishes, and a cat")
assert not match("(?<!cat)fish", "cat catfish dog", Flags => RegexPerl)
assert     match("(?<!cat)fish", "cat swordfish dog", Flags => RegexPerl)
s = "catfish cat dog"
assert match("cat(?!fish)", s, Flags => RegexPerl)
assert(substring(lastMatch#0#0, lastMatch#0#1 + 4, s) == "cat dog")
assert match("cat(?=fish)", s, Flags => RegexPerl)
assert(substring(lastMatch#0#0, lastMatch#0#1 + 4, s) == "catfish")

-- tests for regexQuote
assert match(regexQuote "foo\\", "foo\\")
assert match(regexQuote "foo^", "foo^")
assert match(regexQuote "foo$", "foo$")
assert match(regexQuote "foo.", "foo.")
assert match(regexQuote "foo|", "foo|")
assert match(regexQuote "foo?", "foo?")
assert match(regexQuote "foo*", "foo*")
assert match(regexQuote "foo+", "foo+")
assert match(regexQuote "(foo)", "(foo)")
assert match(regexQuote "[foo]", "[foo]")
assert match(regexQuote "{foo}", "{foo}")

-- the following matches would all return true without regexQuote
assert not match(regexQuote "\\w",  "foo")
assert not match(regexQuote "^foo", "foo")
assert not match(regexQuote "foo$", "foo")
assert not match(regexQuote "foo.", "fooo")
assert not match(regexQuote "f|oo", "oo")
assert not match(regexQuote "foo?", "fo")
assert not match(regexQuote "foo*", "fo")
assert not match(regexQuote "foo+", "foo")
assert not match(regexQuote "(foo)", "foo")
assert not match(regexQuote "[foo]", "foo")
assert not match(regexQuote "foo{1}", "foo")
