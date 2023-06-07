[![Verify](https://github.com/iglinsek-sa/git-versioning/actions/workflows/verify.yml/badge.svg)](https://github.com/iglinsek-sa/git-versioning/actions/workflows/verify.yml)

# Version generation action

This action is used to generate tags for containers versioning:

## Customizing

### Inputs

Following inputs can be used as `step.with` keys

| Name | Type | Description |
|------|------|---------------|
|`image-name` |String|Container image name to add tag to |
|`is-release`|Boolean|Is this a release or a pre-release version (default: `false`)|
|`generate-metadata-file`|Boolean|Generate metadata.json file (default: `true`)|
|`release-tag`|String|Container release tag for latest version used for CI (default: `latest`)|
|`pre-release-tag`|String|Container pre release tag for development builds used for CI (default: `develop`)|

### Outputs
Following outputs are available

| Name          | Type    | Description                                                                                |
|---------------|---------|--------------------------------------------------------------------------------------------|
|`docker-tags`|List|Container generated tags|
|`git-tag`|String|Git tag for release|