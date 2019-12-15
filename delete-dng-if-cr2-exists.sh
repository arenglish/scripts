#!/bin/bash

FILES=./*
CR2=".cr2"
for f in $FILES
do
  if [[ $f = *$CR2 ]]; then
    echo "Found CR2: $f"
  fi
done
