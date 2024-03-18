set -euo pipefail

echo >&2 "git checkout main"
git checkout main

echo >&2 'nix develop .#ci-doc --command bash -c "make doc"'
nix develop .#ci-doc --command bash -c "make doc"

if [[ -z "$(git status --short)" ]]
then
    echo >&2 'Nothing to commit and push!'
else
    git config --local user.name 'NACAMURA Mitsuhiro'
    git config --local user.email 'm15@m15a.dev'

    echo >&2 "git remote set-url --push origin $DST_URL"
    git remote set-url --push origin "$DST_URL"

    echo >&2 "git add doc"
    git add doc

    echo >&2 "git commit -m 'docs: auto update'"
    git commit -m 'docs: auto update'

    echo >&2 "git push origin main"
    git push origin main
fi
