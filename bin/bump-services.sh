#!/bin/bash
find -name "*.yml" -exec grep -q $1 {} \; -print -exec sed -i s/$1/$2/g {} \;
