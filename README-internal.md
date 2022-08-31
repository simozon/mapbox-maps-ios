## Mapbox Maps SDK private for iOS

This repository is a private fork of https://github.com/mapbox/mapbox-maps-ios, with premium features.

## Getting Started

As this repo is a private clone of the public SDK, to be able to sync with the public repo, we can do the following setup:

1. Clone this repo.
2. Add the public SDK repo https://github.com/mapbox/mapbox-maps-ios as remote to fetch (potential) future changes. Make sure you also disable push on the remote (as you are not allowed to push to it anyway).

```
git remote add public git@github.com:mapbox/mapbox-maps-ios.git
git remote set-url --push public DISABLE
```

A good idea would be to rename the private repo remote from the default "origin" to "private".

When you push, do so on private with git push private.

When you want to pull changes from public repo you can just fetch the remote and rebase on top of your work.
```
git fetch public
git rebase public/main
```
And solve the conflicts if any.

## Branches

* `main` branch - the same main branch as the public repo, used to fetch new changes from upstream.
* `internal` branch - the default branch for the private repo, includes all the necessary changes to build and maintain private features.
* Release branches(e.g. `v10.7-private`) - The branches for the private releases.

## Work on a release

Currently the CI is not set up to automate the release process, release can only be done manually. 

### Release manually
TBD
