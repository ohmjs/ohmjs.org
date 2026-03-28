#! /bin/bash

unlink docs/images
cp -r ../ohm/doc/* docs
rm docs/README.md # Only used on GitHub
rm -rf static/img/docs
mv docs/images static/img/docs
ln -s ../static/img/docs docs/images
