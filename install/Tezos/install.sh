#!/usr/bin/env bash

#
# xiechnegqi
# 2021/08/09
# docker-compose install Tezos
#

main() {

# get net option
[ "$1" = "mainnet" ] && net="mainnet" || net="testnet"

# environments
# new install script url
# installScriptUrl="https://gitlab.com/tezos/tezos/raw/latest-release/scripts/tezos-docker-manager.sh"
# old install script url
installScriptUrl="https://gitlab.com/tezos/tezos/raw/carthagenet/scripts/alphanet.sh"

# install script url
dockerUrl="curl -SsL https://raw.githubusercontent.com/Xiechengqi/scripts/master/install/Docker/install.sh | bash"
dockerComposeUrl="curl -SsL https://raw.githubusercontent.com/Xiechengqi/scripts/master/install/Docker/docker-compose/install.sh | bash"

# install docker and docker-compose
curl -SsL $dockerUrl | bash
curl -SsL $dockerComposeUrl | bash

# check install path
EXEC "rm -rf $installPath"
EXEC "mkdir -p $installPath"

# install
[ "$net" = "mainnet" ] && fileName="mainnet" || fileName="carthagenet"
EXEC "curl $installScriptUrl -o $installPath/${fileName}.sh"
EXEC "chmod +x $installPath/${fileName}.sh"

# forbid image auto update
cat > /etc/profile.d/tezos.sh << EOF
export TEZOS_ALPHANET_DO_NOT_PULL=yes
export TEZOS_MAINNET_DO_NOT_PULL=yes
EOF
EXEC "source /etc/profile.d/tezos.sh"

# start
EXEC "bash $installPath/${fileName}.sh start --rpc-port 0.0.0.0:8732"

# info
YELLOW "bash $installPath/${fileName}.sh head" && bash $installPath/${fileName}.sh head
YELLOW "bash $installPath/${fileName}.sh node status" && bash $installPath/${fileName}.sh node status
}

main $@
