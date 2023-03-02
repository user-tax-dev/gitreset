#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))

cd $DIR

set -ex

git pull


./build.sh
git add -u || true
npm version patch --no-git-tag-version
git add -u
version=$(cat package.json | jq -r '.version')
git commit -m v$version || true
git push
npm publish --access=public
