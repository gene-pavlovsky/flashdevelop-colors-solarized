# ******************************************************************************
# Syntax Coloring (common, applied before theme-specific script)
#

s,{caret-fore},{base2},g
s,{caretline-back},{base02},g
s,{selection-fore},{base2},g
s,{selection-back},{base01},g
s,{margin-fore},{base03},g
s,{margin-back},{base03},g
s,{marker-fore},{base03},g
s,{marker-back},{base01},g
s,{highlight-back},{green-hi},g
s,{highlightword-back},{cyan-med},g
s,{modifiedline-back},{yellow},g

s,{font-size},"11",g;
s,{font-face},"Consolas",g
s,{default-fore},{base1},g
s,{default-back},{base03},g

s,{comment-fore},{base01},g
s,{commentdoc-fore},{base00},g
s,{commentdockeyword-fore},{base0},g
s,{commentdockeyworderror-back},{red},g

s,{number-fore},{cyan},g
s,{xml-number-fore},{blue},g
s,{character-fore},{green},g
s,{string-fore},{green},g
s,{verbatim-fore},{green},g
s,{stringeol-fore},{green},g
s,{preprocessor-fore},{orange},g
s,{regex-fore},{magenta},g

s,{operator-fore},{yellow},g
s,{xml-php_operator-fore},{blue},g

s,{word-fore},{violet},g
s,{python-word-fore},{yellow},g
s,{word2-fore},{blue},g
s,{word3-fore},{orange},g
s,{word5-fore},{blue},g
s,{globalclass-fore},{yellow},g

s,{gdefault-fore},{base02},g
s,{linenumber-fore},{base00},g

s,{bracelight-fore},{red},g
s,{bracelight-back},{base02},g

s,{indentguide-fore},{base02},g

s,[a-z][-_a-z0-9]*={\(word4\|bracebad\)-[a-z]*},,g
