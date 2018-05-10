#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

jazzy \
    --clean \
    --author 'Patrick Piemonte' \
    --author_url 'http://patrickpiemonte.com/' \
    --github_url 'http://github.com/piemonte/Poly' \
    --sdk iphonesimulator \
    --xcodebuild-arguments -scheme,Poly \
    --module 'Poly' \
    --framework-root . \
    --readme README.md \
    --output docs/
