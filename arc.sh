#!/bin/bash
 
if [ -L "$0" ]; then
  arc_dir=`readlink $0`
else
  arc_dir=$0
fi
arc_dir=`dirname $arc_dir`

mzscheme="mzscheme -q -m -d"

if [ "$(type -p rlwrap)" -a ! "$1" = "--no-rl" ]; then
  rlwrap -C arc $mzscheme "$arc_dir/as.scm"
else
  $mzscheme "$arc_dir/as.scm"
fi