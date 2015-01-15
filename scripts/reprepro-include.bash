#!/bin/bash

# This script will add a deb to the 'building' APT repository, using reprepro

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export BUILD_DIR=`readlink -f ${SCRIPT_DIR}/..`

if [[ ${#} -lt 4 ]]; then
    echo "Usage: ${0} <pkg_name> <name.deb> <distro> <arch>"
    exit -1
fi
export PKG=${1}
export NAME=${2}
export DISTRO=${3}
export ARCH=${4}

export APTLY_CMD='aptly -config=/buildbot-ros/aptly.conf'

source /buildbot-ros/conf/aptly-distributions.conf

# TODO: invalidate dependent (if desired)
# remove old version of this package
${APTLY_CMD} repo remove building $PKG
# add new package to repo
${APTLY_CMD} repo add building $BUILD_DIR/binarydebs/$NAME
# update the published repository files
for distro in ${APTLY_DISTRIBUTIONS[@]}; do
  ${APTLY_CMD} publish update ${distro}
done
