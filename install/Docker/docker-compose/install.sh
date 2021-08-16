#!/usr/bin/env bash

#
# 2021/08/09
# xiechengqi
# install docker-compose
#

source /etc/profile
source <(curl -SsL https://gitee.com/Xiechengqi/scripts/raw/master/tool/common.sh)

OS() {
osType=$1
osVersion=$2
curl -SsL https://raw.githubusercontent.com/Xiechengqi/scripts/master/tool/os.sh | bash -s ${osType} ${osVersion} || exit 1
}

main() {
version=${1-"1.29.2"}
countryCode=`curl -SsL https://api.ip.sb/geoip | sed 's/,/\n/g' | grep country_code | awk -F '"' '{print $(NF-1)}'`
[ "$countryCode" = "CN" ] && downloadUrl="https://get.daocloud.io/docker/compose/releases/download/${version}/docker-compose-`uname -s`-`uname -m`" || downloadUrl="https://github.com/docker/compose/releases/download/${version}/docker-compose-`uname -s`-`uname -m`"

# check service
docker-compose version &> /dev/null && YELLOW "docker-compose has been installed ..." && return 0

# download
EXEC "curl -SsL $downloadUrl > /usr/local/bin/docker-compose"

# register bin
EXEC "chmod +x /usr/local/bin/docker-compose"

# info
EXEC "docker-compose version" && docker-compose version
}

main $@
