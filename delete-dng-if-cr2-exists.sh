#!/bin/bash

FILES=./*
CR2=".cr2"
for f in $FILES
do
  if [[ $f = *$CR2 ]]; then
    FILENAME="$f/$CR2/''"
    echo "Found CR2: $FILENAME"
  fi
done
