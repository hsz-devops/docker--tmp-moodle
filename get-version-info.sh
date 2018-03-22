#!/usr/bin/env bash
#
# v1.0.0    2018-03-22    webdev@highskillz.com
#
# Gets version info from Moodle install dir + git hash
#
# Output file can be used as global variables
#     source /tmp/verinfo.ver && echo $CHKVER_VERSION_FULL
#
# Can also be used as local variables
#     env $(cat /tmp/verinfo.ver |grep -v ^# |xargs         ) bash -c 'echo / $CHKVER_VERSION_FULL / $CHKVER_PROD_TYPE /'
#     env $(./_docker/get-version-info.sh                   ) bash -c 'echo / $CHKVER_VERSION_FULL / $CHKVER_PROD_TYPE /'
#     env $(./_docker/get-version-info.sh             |xargs) bash -c 'echo / $CHKVER_VERSION_FULL / $CHKVER_PROD_TYPE /'
#     env $(./_docker/get-version-info.sh |grep -v ^# |xargs) bash -c 'echo / $CHKVER_VERSION_FULL / $CHKVER_PROD_TYPE /'

# since we may be outputting "bash env" compatible output, we should be silent
set +x
[ -z "$1" ] || set -x

#
set -e
set -o pipefail

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
T_STAMP=$(date -u +"%Y%m%dT%H%M%SZ")

PROD_TYPE=moodle3x
VERSION_FILE="./version.php"

[ -f "${VERSION_FILE}"         ] || exit -1
[ -f "./config-dist.php"  ] || exit -3
[ -f "./file.php"         ] || exit -5
[ -f "./help.php"         ] || exit -7
[ -f "./admin/cli/install.php"  ] || exit -9
[ -f "./theme/clean/config.php" ] || exit -11

CHKVER_PROD_VERSION_FULL_DOTTED=$(grep "\$release" ${VERSION_FILE} |sed "s/[';]//g" |cut -d"=" -f 2| cut -d"(" -f 1| sed "s/[ ]//g")
CHKVER_PROD_VERSION_FULL_NODOTS=$(echo ${CHKVER_PROD_VERSION_FULL_DOTTED} | sed "s/\.//g")
CHKVER_PROD_RELDATE_FULL=$(grep "\$release" ${VERSION_FILE} |sed "s/[';]//g" |cut -d":" -f 2 |cut -d")" -f 1 | sed "s/[ ]//g")

# check if the minimum varibles are set
[ -z "${CHKVER_PROD_VERSION_FULL_DOTTED}" ] && exit -31
[ -z "${CHKVER_PROD_VERSION_FULL_NODOTS}" ] && exit -32
[ -z "${CHKVER_PROD_RELDATE_FULL}"        ] && exit -33

# git is optional (not present if source is .tgz)
if [ -d ./.git/ -o -f ./.git ]; then
    CHKVER_GIT_SHA_LONG=$(git  rev-parse --verify         HEAD)
    CHKVER_GIT_SHA_SHORT=$(git rev-parse --verify --short HEAD)
fi

# --------------------------------------------------------------------------------
if [ -z "$1" ]; then
    # output to stdout
    echo CHKVER_TSTAMP=${T_STAMP}
    echo CHKVER_PROD_TYPE=${PROD_TYPE}
    echo CHKVER_VERSION_FULL_DOTTED=${CHKVER_PROD_VERSION_FULL_DOTTED}
    echo CHKVER_VERSION_FULL_NODOTS=${CHKVER_PROD_VERSION_FULL_NODOTS}
    [ -z "${CHKVER_GIT_SHA_LONG}"  ] || echo CHKVER_GIT_SHA_LONG=${CHKVER_GIT_SHA_LONG}
    [ -z "${CHKVER_GIT_SHA_SHORT}" ] || echo CHKVER_GIT_SHA_SHORT=${CHKVER_GIT_SHA_SHORT}
else
    # output to file
    if [ -f "$1" ]; then
        if [ -z "ALLOW_CHKVER_OVERWRITE" ]; then
            echo "Target file already exists [$1]. Aborting!"
            exit -10
        fi
    fi
    echo ""                                            >  "$1"
    echo CHKVER_TSTAMP=${T_STAMP}                      >> "$1"
    echo CHKVER_PROD_TYPE=${PROD_TYPE}                 >> "$1"
    echo CHKVER_VERSION_FULL_DOTTED=${CHKVER_PROD_VERSION_FULL_DOTTED} >> "$1"
    echo CHKVER_VERSION_FULL_NODOTS=${CHKVER_PROD_VERSION_FULL_NODOTS}  >> "$1"
    [ -z "${CHKVER_GIT_SHA_LONG}"  ] || echo CHKVER_GIT_SHA_LONG=${CHKVER_GIT_SHA_LONG}    >> "$1"
    [ -z "${CHKVER_GIT_SHA_SHORT}" ] || echo CHKVER_GIT_SHA_SHORT=${CHKVER_GIT_SHA_SHORT}  >> "$1"
fi
