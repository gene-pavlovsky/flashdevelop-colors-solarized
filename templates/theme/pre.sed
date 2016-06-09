#!/bin/sed -f
#
# Theme (common, applied before theme-specific script)
#

s,{background1},{base03},g
s,{background2},{base02},g
s,{content1},{base01},g
s,{content2},{base00},g
s,{content3},{base0},g
s,{content4},{base1},g
s,{highlight1},{base2},g
s,{highlight2},{base3},g

s,{highlight-back},{blue},g

s,{caption-fore},{base2},g
s,{search-fore},{base2},g
s,{header-fore},{base2},g
s,{grid-line-color},{base02},g
