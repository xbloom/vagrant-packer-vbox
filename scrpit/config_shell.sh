#!/bin/bash

set -euo pipefail

# shellcheck source=./common.sh
CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CURR_DIR" ] || { echo "找不到common.sh, 请检查.";  exit 1; }
source "$CURR_DIR/common.sh"
export PATH=$PATH:$CURR_DIR



echo "检查docker阿里云镜像"
if [ ! -d "/etc/docker" ]; then
    mkdir -p /etc/docker
fi
if [ ! -f "/etc/docker/daemon.json" ]; then
    sudo tee /etc/docker/daemon.json <<- EOF
{
    "insecure-registries":["172.16.5.220:5000"]
}
EOF
    sudo usermod -a -G docker vagrant
    sudo systemctl enable docker
    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi




step "检查jq"
if ! [[ -x "$(command -v jq)" ]]; then
    echo 'installing jq.' >&2
    dnf install -y jq nc bash-completion
fi

step "检查bat"
if ! command -v bat &> /dev/null ; then
    echo "installing bat"
    BAT_VERSION=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Eo '"tag_name": "v(.*)"' | sed -E 's/.*"([^"]+)".*/\1/')
    BAT_RELEASE="bat-$BAT_VERSION-x86_64-unknown-linux-musl"
    BAT_ARCHIVE="$BAT_RELEASE.tar.gz"
    curl -SsL "https://ghproxy.com/https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/$BAT_ARCHIVE" | tar -xzf - -C /tmp/
    sudo cp /tmp/$BAT_RELEASE/bat /usr/local/bin/bat
    rm -rf /tmp/$BAT_RELEASE/
fi

step "检查yq"
if ! command -v yq &> /dev/null ; then
    echo 'installing yq.' >&2
    YQ_VERSION=$(curl --silent "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep -Eo '"tag_name": "v(.*)"' | sed -E 's/.*"([^"]+)".*/\1/')
    YQ_ARCHIVE="yq_linux_amd64.tar.gz"
    echo "download => https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_ARCHIVE"
    curl -SsL "https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_ARCHIVE" | tar -xzf - -C /tmp/
    sudo mv /tmp/yq_linux_amd64 /usr/local/bin/yq
    yq --version
fi

step "检查kubectl"
if ! command -v kubectl &> /dev/null ; then
    echo 'installing yq.' >&2
    curl -LO "https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl" && chmod 755 kubectl
    sudo install kubectl /usr/local/bin/
fi



step "检查密钥 git.wowkai.cn"
gitlab_host="git.wowkai.cn"
if ! [ -f "$CURR_DIR/gitlab_keypair" ]; then
    section 'installing git key.'
    set -eu
    # GitProvider="git.wowkai.cn"
    # GitUsername="chaojidaogou.com"
    # cat ./gitlab.keys && rm ./gitlab.keys
    # curl -su 'liusijin@chaojidaogou.com' https://${GitProvider}/${GitUsername}.keys | tee -a ./gitlab.keys
    # cat ./gitlab.keys || true
    
    # gitlab_user="liusijin@chaojidaogou.com"
    # gitlab_password=""

    echo y | ssh-keygen -t ed25519 -q -N "" -f "$CURR_DIR/gitlab_keypair"
    chmod 600 "$CURR_DIR/gitlab_keypair"
    chmod 600 "$CURR_DIR/gitlab_keypair.pub"
    cp "$CURR_DIR/gitlab_keypair" ~/.ssh/

    chmod 600 ~/.ssh/gitlab_keypair
    # openssl genrsa -out gitlab_keypair.pem 2048
    # openssl rsa -in gitlab_keypair.pem -pubout -out gitlab_pub.crt
    # openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in gitlab_keypair.pem -out gitlab_pkcs8.key

    cat > ~/.ssh/config <<- EOF
Host ${gitlab_host}
    Port 10080
    StrictHostKeyChecking no
    IdentityFile ~/.ssh/gitlab_keypair
EOF
    chmod 600 ~/.ssh/config
    body_header=$(curl -s -c cookies.txt -i "https://${gitlab_host}/users/sign_in")
    csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
    
    echo
    echo "请输入 $gitlab_host....."
    read -p  '用户名: ' gitlab_user
    read -sp '密  码: ' gitlab_password

    curl -s -b cookies.txt -c cookies.txt -i "https://${gitlab_host}/users/sign_in" \
        --data "user[login]=${gitlab_user}&user[password]=${gitlab_password}" \
        --data-urlencode "authenticity_token=${csrf_token}"

    body_header=$(curl -s -H 'user-agent: curl' -b cookies.txt -i "https://${gitlab_host}/profile/personal_access_tokens")
    csrf_token=$(perl -ne 'print "$1\n" if /authenticity_token"[[:blank:]]value="(.+?)"/' <<< $body_header | sed -n 1p)
    
    body_header=$(curl -sL -b cookies.txt "https://${gitlab_host}/profile/personal_access_tokens" \
        --data-urlencode "authenticity_token=${csrf_token}" \
        --data 'personal_access_token[name]=vagrant-box-generated&personal_access_token[expires_at]=&personal_access_token[scopes][]=api')
    personal_access_token=$(perl -ne 'print "$1\n" if /created-personal-access-token"[[:blank:]]value="(.+?)"/' <<<$body_header| sed -n 1p)
    echo "valid pat=> $personal_access_token"

    # curl --header "Private-Token: ${personal_access_token}" https://gitlab.example.com/api/v4/projects
    
    curl -s "https://${gitlab_host}/api/v4/user/keys" --header "Private-Token: ${personal_access_token}"

    curl -s "https://${gitlab_host}/api/v4/user/keys" \
        --header "Private-Token: ${personal_access_token}" \
        -F "title=vagrant_auto_gen" \
        -F "key=$(cat $CURR_DIR/gitlab_keypair.pub)" | jq
        # --data "{\"title\":\"vagrant_auto_gen\",\"key\":\"$(cat gitlab_keypair.pub)\"}"
fi

if ssh -T "git@${gitlab_host}" ; then
    echo "gitlab ssh key正常"
else
    warn "gitlab ssh key异常"
fi

step "完成"