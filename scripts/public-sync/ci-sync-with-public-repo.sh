#!/usr/bin/env bash

set -v
set -euo pipefail

readonly BRANCH=$1

if [[ -z $BRANCH ]]
then
  echo "Usage : ./ci-sync-with-public.sh <branch name to sync>"
  exit 1
fi

readonly GITHUB_TOKEN=$(mbx-ci github writer private token)
readonly COMMIT_SHA=$(git rev-parse --abbrev-ref HEAD)

# fetch public branch
git remote add public-maps https://x-access-token:"$GITHUB_TOKEN"@github.com/mapbox/mapbox-maps-ios.git
git remote set-url --push public-maps DISABLE
git fetch public-maps ${BRANCH}

# release branch won't exist after is cut for the first time
PUBLIC_BRANCH_EXISTS=$(git ls-remote origin $BRANCH | wc -l)
if [[ $PUBLIC_BRANCH_EXISTS -eq 0 ]]; then
  echo "Public $BRANCH doesn't exist in the private repo, cut it from the latest public and push to the private repo."
  git checkout -B ${BRANCH} public-maps/${BRANCH}
else
  echo "Public $BRANCH exists in the private repo, merge it and push to the private repo."
  git checkout -B ${BRANCH} origin/${BRANCH}
  git merge public-maps/${BRANCH}
fi

# remove public remote
git remote remove public-maps
# set access token associated with mapbox-ci user
git remote set-url origin https://x-access-token:"$GITHUB_TOKEN"@github.com/mapbox/mapbox-maps-ios-private.git

git push origin ${BRANCH}

git checkout ${COMMIT_SHA}