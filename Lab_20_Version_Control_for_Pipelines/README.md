# Pipeline Version Control Repository

This repository contains Tekton pipeline definitions and related resources,
managed using Git for version control.

## Directory Structure

- pipelines/build   : Build pipeline definitions
- pipelines/deploy  : Deployment pipeline definitions
- tasks             : Reusable Tekton Task definitions
- environments/dev  : Development environment pipeline variants
- environments/prod : Production environment pipeline variants
- scripts           : Helper scripts (versioning, validation)
- automation        : Rollback and deployment automation scripts

## Versioning

Pipeline versions are tracked with:
1. A `version` label inside each pipeline's metadata
2. Git tags following semantic versioning (vMAJOR.MINOR.PATCH)
