#!/usr/bin/env bash

# 
# xiechengqi
# OS: Ubuntu 18.04
# 2021/08.04
# install Conflux Node
# 

source /etc/profile
BASEURL="https://gitee.com/Xiechengqi/scripts/raw/master"
source <(curl -SsL $BASEURL/tool/common.sh)

main() {
# check os
osInfo=`get_os` && INFO "current os: $osInfo"
! echo "$osInfo" | grep -E 'ubuntu18|ubuntu20' &> /dev/null && ERROR "You could only install on os: ubuntu18、ubuntu20"

# get chainId
chainId="$1" && INFO "chain: $chainId"                                                                                                
! echo "$chainId" | grep -E 'mainnet|testnet' &> /dev/null && ERROR "You could only choose chain: mainnet、testnet"

# environments
serviceName="conflux-node"
version="1.1.4"
installPath="/data/Conflux/${serviceName}-${version}"
[ "$chainId" = "mainnet" ] && downloadUrl="https://github.com/Conflux-Chain/conflux-rust/releases/download/v${version}/conflux_linux_v${version}.zip" || downloadUrl="https://github.com/Conflux-Chain/conflux-rust/releases/download/v${version}-testnet/conflux_linux_v${version}-testnet.zip"

# check service
systemctl is-active $serviceName &> /dev/null && YELLOW "$serviceName is running ..." && return 0 

# check install path
EXEC "rm -rf $installPath $(dirname $installPath)/${serviceName}"
EXEC "mkdir -p $installPath/{bin,conf,data,logs}"

# install unzip
EXEC "apt update && apt install -y unzip"

# download
EXEC "rm -rf /tmp/${serviceName} && mkdir /tmp/${serviceName}"
EXEC "curl -SsL $downloadUrl -o /tmp/${serviceName}/${serviceName}.zip"
EXEC "unzip /tmp/${serviceName}/${serviceName}.zip -d /tmp/${serviceName}"
EXEC "mv /tmp/${serviceName}/run/conflux $installPath/bin"
EXEC "mv /tmp/${serviceName}/run/*.toml /tmp/${serviceName}/run/*.yaml $installPath/conf"
EXEC "cd /tmp && rm -rf ${serviceName} && cd -"

# register bin
EXEC "ln -fs $installPath/bin/* /usr/local/bin"

# config
INFO "sed -i \"s#log\/#$installPath\/logs\/#g\" $installPath/conf/log.yaml"
sed -i "s#log\/#$installPath\/logs\/#g" $installPath/conf/log.yaml

# create start.sh
[ "$chainId" = "mainnet" ] && configFileName="tethys.toml" || configFileName="testnet.toml"
echo "conflux_data_dir = \"$installPath/data\"" >> $installPath/conf/${configFileName}
cat > $installPath/start.sh << EOF
#!/usr/bin/env bash
source /etc/profile

export RUST_BACKTRACE=1
conflux --config $installPath/conf/${configFileName} --log-conf $installPath/conf/log.yaml &> $installPath/logs/error.log 1> /dev/null
EOF
EXEC "chmod +x $installPath/start.sh"

# register service
cat > /lib/systemd/system/${serviceName}.service << EOF
[Unit]
Description=A BPoS blockchain that enables cross-chain interoperability through a unified service model
Documentation=https://github.com/irisnet/irishub
After=network.target

[Service]
User=root
Group=root
ExecStart=/bin/bash $installPath/start.sh
ExecStop=/bin/kill -s QUIT \$MAINPID
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

# change softlink
EXEC "ln -fs $installPath $(dirname $installPath)/${serviceName}"

# start
EXEC "systemctl daemon-reload && systemctl enable $serviceName && systemctl start $serviceName"
EXEC "systemctl status $serviceName --no-pager" && systemctl status $serviceName --no-pager

# INFO
YELLOW "version: ${version}"
YELLOW "install path: $installPath"
YELLOW "config path: $installPath/conf"
YELLOW "data path: $installPath/data"
YELLOW "log path: $installPath/logs"
YELLOW "connection cmd: "
YELLOW "managemanet cmd: systemctl [stop|start|restart|reload] $serviceName"
}

main $@
