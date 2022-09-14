#!/usr/bin/env bash

set -v
set -euo pipefail
set -x

readonly BRANCH=$1
PRIVATE_BRANCH="public/$BRANCH"

if [[ -z $BRANCH ]]
then
  echo "Usage : ./ci-sync-with-public-repo.sh <branch name to sync>"
  exit 1
fi

COMMIT_SHA=$(git rev-parse --abbrev-ref HEAD)
readonly COMMIT_SHA

# fetch public branch
git remote add public-maps https://x-access-token:"$(mbx-ci github reader token)"@github.com/mapbox/mapbox-maps-ios.git
git remote set-url --push public-maps DISABLE
git fetch public-maps "$BRANCH"

# release branch won't exist after is cut for the first time
PUBLIC_BRANCH_EXISTS=$(git ls-remote origin "$PRIVATE_BRANCH" | grep -c "heads/$PRIVATE_BRANCH")
if [[ $PUBLIC_BRANCH_EXISTS -eq 0 ]]; then
  echo "Public $BRANCH doesn't exist in the private repo ($PRIVATE_BRANCH), cut it from the latest public and push to the private repo."
  git checkout -B "$PRIVATE_BRANCH" "public-maps/$BRANCH"
else
  echo "Public $BRANCH exists in the private repo ($PRIVATE_BRANCH), merge it and push to the private repo."
  git checkout -B "$PRIVATE_BRANCH" "origin/$PRIVATE_BRANCH"
  git merge "public-maps/$BRANCH"
fi

# remove public remote
git remote remove public-maps
# set access token associated with mapbox-ci user
git remote set-url origin https://x-access-token:"$(mbx-ci github writer private token)"@github.com/mapbox/mapbox-maps-ios-private.git

git push -u origin "$PRIVATE_BRANCH"

git checkout "$COMMIT_SHA"