#!/bin/bash
jazzy \
  --clean \
  --author "Soar Group" \
  --author_url http://soar.eecs.umich.edu \
  --github_url https://github.com/bluechill/Domains-DiceiOS \
  --github-file-prefix https://github.com/bluechill/Domains-DiceiOS/blob/3.0-rewrite \
  --module-version 3.0 \
  --module "DiceLogicEngine" \
  --xcodebuild-arguments -scheme,"DiceLogicEngine" \
  --output docs/swift
