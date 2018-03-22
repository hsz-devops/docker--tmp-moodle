#!/usr/bin/env bash
#
# v1.0.0    2018-03-06    webdev@highskillz.com
#
# cli params:
#   <NN> [(git | curl) [<dest-dir>]]
#
#    NN            moodle version (31, 32, 33, 34, ...)
#    git | curl    which method to use in fetching
#    <dest-dir>    where to leave moodle
#
set -e
set -o pipefail
set -x

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
T_STAMP=$(date -u +"%Y%m%d_%H%M%SZ")

MDL__FETCH_MODE=${MDL__FETCH_MODE:-git}

MDL__SRC_GIT="${MDL__SRC_GIT:-git://git.moodle.org/moodle.git}"
MDL__SRC_TGZ="${MDL__SRC_TGZ:-https://download.moodle.org/download.php/direct}"

MDL__DEST_DIR="${MDL__DEST_DIR:-/usr/local/moodle}"

if [ -z "$1" ]; then
    echo "Must specify a moodle version in NN format. Exiting!"
    exit -1
fi
MDL__VERSION="$1"
shift

if [ -n "$1" ]; then
    MDL__DEST_DIR="$1"
    shift
fi

if [ -n "$1" ]; then
    MDL__FETCH_MODE="$1"
    shift
fi

mkdir -p "$(dirname ${MDL__DEST_DIR})"

case "${MDL__FETCH_MODE}" in
    "git")
        mkdir -p /tmp/temp
        pushd /tmp/temp
        if [ -d ./moodle -a "${DOCKER_MOODLE_SKIP_EXISTS}" != "0" ]; then
            echo "Moodle GIT seems to already exist in [/tmp/temp/moodle/]... skipping pull..."
        else
            time git clone -b "MOODLE_${MDL__VERSION}_STABLE" --depth=1 git://git.moodle.org/moodle.git moodle

            pushd moodle

                ${THIS_DIR}/get-version-info.sh "${MDL__DEST_DIR}/.chkver.env"

                rm -rf .git
            popd
        fi
        popd
    ;;
    "curl")
        mkdir -p /tmp/temp
        pushd /tmp/temp
        if [ -f ./moodle-latest.tgz -a "${DOCKER_MOODLE_SKIP_EXISTS}" != "0" ]; then
            echo "Moodle TGZ seems to already exist in [/tmp/moodle-latest.tgz]... skipping download..."
        else
            # https://download.moodle.org/download.php/direct/stable${MDL__VERSION}/moodle-latest-${MDL__VERSION}.tgz
            time curl "${MDL__SRC_TGZ}/stable${MDL__VERSION}/moodle-latest-${MDL__VERSION}.tgz" -o ./moodle-latest.tgz
        fi
        #rm /var/www/html/index.html
        tar xzf ./moodle-latest.tgz
        pushd ./moodle
            ${THIS_DIR}/get-version-info.sh "${MDL__DEST_DIR}/.chkver.env"
        popd

        rm -rf ./moodle-latest.tgz
        popd
    ;;
    *)
        exit -11
    ;;
esac

if [ "${MDL__DEST_DIR}/src" != "/tmp/temp/moodle" ]; then
    mv /tmp/temp/moodle ${MDL__DEST_DIR}
fi

ls -la "$(dirname ${MDL__DEST_DIR})"
ls -la "${MDL__DEST_DIR}"

[ -f "${MDL__DEST_DIR}/moodle/config-dist.php" ] || exit -21
[ -f "${MDL__DEST_DIR}/moodle/install.php"     ] || exit -22
[ -f "${MDL__DEST_DIR}/moodle/version.php"     ] || exit -23

echo "Moodle successfully fetched!!!"
