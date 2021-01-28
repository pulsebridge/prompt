#! /usr/bin/env sh

set -e

# install prerequisites
./hack/prerequisites.sh

# install and test bash
./hack/install.sh bash
./hack/test.sh bash

# install and test yum
./hack/install.sh zsh
./hack/test.sh zsh
