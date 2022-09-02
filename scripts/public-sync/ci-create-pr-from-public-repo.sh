#!/usr/bin/env bash

set -v
set -euo pipefail
set -x

if ! command -v gh &> /dev/null
then
    echo "gh (github cli tool) is not found, install it first"
    exit 1
fi

readonly BRANCH=$1
ORIGIN_BRANCH="public/$BRANCH"

if [[ -z $BRANCH ]]
then
  echo "Usage : ./ci-create-pr-from-public-repo.sh <branch name to sync>"
  exit 1
fi

if [[ "main" == "$BRANCH" ]]; then
  # handle main private branch (aka `internal`)
  PRIVATE_BRANCH="internal"
else
  # handle release private branch
  PRIVATE_BRANCH="$BRANCH-private"
fi

COMMIT_SHA=$(git rev-parse --abbrev-ref HEAD)

readonly MERGE_BRANCH=ci-${PRIVATE_BRANCH}-${BRANCH}-merge
readonly TITLE="${PRIVATE_BRANCH} to ${BRANCH} merge."
BODY=$(cat << END
This PR is created automatically by CircleCI to sync private ``${PRIVATE_BRANCH}`` branch with public ``${BRANCH}`` branch after update.
END
)

git fetch origin "$ORIGIN_BRANCH"

# private release branch may be fresh and not exist yet
# in this case we cut a new branch from the latest internal and push it afterwards
PRIVATE_BRANCH_EXISTS=$(git ls-remote origin "$PRIVATE_BRANCH" | grep -c "heads/$PRIVATE_BRANCH")
if [[ $PRIVATE_BRANCH_EXISTS -eq 0 ]]; then
  echo "$PRIVATE_BRANCH doesn't exist, create it from the latest internal and push to the repository."
  git checkout -B "$PRIVATE_BRANCH" origin/internal
  git push origin "$PRIVATE_BRANCH"
fi

git fetch origin "$PRIVATE_BRANCH"
# cut a merge branch at the latest public commit
git checkout -B "$MERGE_BRANCH" "origin/$ORIGIN_BRANCH"

# push to create new PR or update an existing one
git push --force -u origin "$MERGE_BRANCH"

GITHUB_TOKEN=$(mbx-ci github writer private token)
export GITHUB_TOKEN

PR_STATE=$(gh pr view "$MERGE_BRANCH" --json state --jq '.state')
if [[ "$PR_STATE" != "OPEN" ]]; then
  gh pr create \
    --title "$TITLE" \
    --body "$BODY" \
    --base "$PRIVATE_BRANCH"
fi

git checkout "$COMMIT_SHA"