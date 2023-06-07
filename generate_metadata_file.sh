#!/bin/bash
#
# Generate docker matadata file
#

#
# Returns the repo's org and name from the remote URL, or optionally the full URL
# @param $1 [String] Optional - Boolean determining whether to return the full repo remote URL
# @param $2 [String] Optional - Exit on error; defaults to true
get_repo_remote_path() {
  local get_full_path=${1:-false}
  local repo_path=$(git remote get-url origin)

  if ${get_full_path}; then
    echo "${repo_path}"
  else
    echo "${repo_path}" | sed "s/^\(.*\)\(\:\|\/\)\(.*\/.*\).git$/\3/"
  fi

  if [[ $? -ne 0 ]]; then
    echo 'ERROR: Unable to retrieve repo name, exiting'
    exit 1
  fi
}

#
# Write the project metadata out to file to be included in the Docker image
# $1 Required - The Docker tag to write out
docker_tag=${1}
git_repo=$(get_repo_remote_path true | sed 's/^git@\(.*\):\(.*\)\(.git\)$/https:\/\/\1\/\2/g')

pushd "${GITHUB_WORKSPACE}" >/dev/null
echo "Writing metadata file to ${GITHUB_WORKSPACE}..."
cat <<-EOF >metadata.json
  {
    "version": "$(echo "${docker_tag##*:}" | cut -d'-' -f1,3)",
    "git_commit": "$(echo "${docker_tag##*:}" | cut -d'-' -f2)",
    "docker_image": "${docker_tag}",
    "git_repo": "${git_repo}"
  }
EOF
popd >/dev/null

if [[ $? -ne 0 ]]; then
  echo "ERROR: An error occurred attempting to write the metadata file, exiting..."
  exit 1
fi
