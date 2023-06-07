#!/bin/bash
#
# Get next version for tagging and docker images
#

#
# Increments the last bit of a given numerical tag
# (e.g., 4.1.7 -> 4.1.8, 9 -> 10, etc.)
# @param $1 [String] Optional - The given tag of which to increment. When blank, will start at version ${prefix}1.0.0
# @param $2 [String] Optional - The prefix of the tag
# @param $3 [String] Optional - Exit on error; defaults to true
increment_tag() {
  local given_tag=${1}
  local prefix=${2:-v}
  local exit_on_error=${3:-true}
  local tag_matcher="^([a-zA-Z]+)?([0-9]*\.[0-9]*\.)([0-9]+)-?([0-9]*)?-?(.*)?$" # 'v<MAJOR>.<MINOR>.<PATCH>-<ADDITIONAL COMMITS SINCE LAST TAG>-<COMMIT HASH>'
  local commit_hash=$(get_current_commit_hash)
  local new_tag

  # Check if the given tag is numerical
  # If it is, increment the last digit
  if [[ ${given_tag} =~ ${tag_matcher} ]]; then
    new_tag="${BASH_REMATCH[1]}${BASH_REMATCH[2]}$((${BASH_REMATCH[3]} + 1))-${commit_hash}"
  elif [[ -z ${given_tag} ]]; then
    # No tag given to increment, so starting at ${prefix}1.0.0
    new_tag="${prefix}1.0.0-${commit_hash}"
  elif ${exit_on_error}; then
    echo "ERROR: Unable to increment tag: '${given_tag}'"
    exit 1
  fi
  echo "${new_tag}"
}

#
# Returns an tag which matches the pattern ${prefix}[0-9]*
# @param $1 [String] Optional - The prefix of the tag to search for
find_valid_tag() {
  local prefix=${1:-v}
  local valid_tag=$(git describe --tags $(git rev-list --tags --max-count=1) --long --match ${prefix}[0-9]* 2>/dev/null || true)

  if [[ -z "${valid_tag}" ]]; then
    echo "v0.0.1"
  fi
  echo "${valid_tag}"
}

#
# Returns the current commit hash, shortened to 8 characters in length
get_current_commit_hash() {
  echo $(git rev-parse --short=8 --verify HEAD)
}

# Returns the next version of the given project path to be released.
# @param $2 [String] Optional - Boolean determining whether to return a regular or SNAPSHOT version
# @param $3 [String] Optional - The prefix of the tag to search for
is_release=${1:-false}
prefix=${2:-v}

pushd "${GITHUB_WORKSPACE}" >/dev/null
# Get previous release tag
previous_release_tag=$(find_valid_tag "${prefix}")

# Attempt to determine the next version, skipping over versions which may already exist
i=0
while [[ i -lt 100 ]]; do
  next_version=$(increment_tag "${previous_release_tag}" "${prefix}" "${exit_on_error}")
  tag_exists=$(git tag -l ${next_version})

  # If tag already exists continue loop. Otherwise exit loop
  if [[ -n ${tag_exists} ]]; then
    previous_release_tag="${next_version}"
  else
    break
  fi

  # Increment counter
  i=$((i++))
done
popd >/dev/null

# Append -SNAPSHOT to the next version if this is not for a release build
if ! ${is_release}; then
  next_version="${next_version}-$(git rev-parse --abbrev-ref HEAD | cut -d '/' -f1)-SNAPSHOT"
fi

if [[ $? -ne 0 ]] && ${exit_on_error}; then
  echo "ERROR: Unable to determine the next tag version, exiting..."
  exit 1
fi

echo "${next_version}"
