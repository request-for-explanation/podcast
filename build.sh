#!/bin/bash

# Usage: ./build.sh episode-directory
# e.g.   ./build.sh ep0-what-the-hell

# rustdoc just spews into a doc folder 🤷‍
mkdir doc

rustdoc --markdown-no-toc --html-in-header src/head.html --html-before-content src/before.html --html-after-content src/after.html "$1/index.md"

# overwrite whatever was there last
mv -f doc/index.html "$1/index.html"

rm -rf doc


