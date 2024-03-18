#!/usr/bin/env bash
# Generate docs, make a commit, and push to $DST_URL.

set -euo pipefail

if [[ -z "${DST_URL:-}" ]]
then
    echo >&2 DST_URL not found.
    exit 1
fi

run() {
    echo >&2 AUTO-UPDATE-DOC: "$@"
    "$@"
}

if [[ "$(git config --get user.name)" != 'Your Name' \
   && -z "$(git config --local --get user.name)" \
   && -z "${GIT_AUTHOR_NAME:-}" ]]
then
    export GIT_AUTHOR_NAME='NACAMURA Mitsuhiro'
fi
if [[ "$(git config --get user.email)" != 'you@example.com' \
   && -z "$(git config --local --get user.email)" \
   && -z "${GIT_AUTHOR_EMAIL:-}" ]]
then
    export GIT_AUTHOR_EMAIL='m15@m15a.dev'
fi

current_branch="$(git branch --show-current)"
target_branch=main

run git checkout "$target_branch"
run make doc

if [[ -z "$(git status --short)" ]]
then
    echo >&2 'Nothing to commit and push!'
else
    current_push_remote="$(git remote get-url --push origin)"
    run git remote set-url --push origin "$DST_URL"
    run git add doc
    run git commit -m 'docs: auto update'
    run git push origin "$target_branch"
    run git remote set-url --push origin "$current_push_remote"
fi

if [ -n "$current_branch" ]
then
    run git checkout "$current_branch"
fi
