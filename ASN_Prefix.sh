#!/bin/bash

ASN=$1
IP_VERSION=$2

if [ -z "$ASN" ] || [ -z "$IP_VERSION" ]; then
    echo "用法: $0 <ASN> <IP_VERSION>"
    echo "IP_VERSION可以是 4, 6, 或 46"
    exit 1
fi

data_dir="$HOME/.pfx2as-data"
mkdir -p "$data_dir"

# 获取当前时间戳和7天前的时间戳
current_time=$(date +%s)
seven_days_ago=$((current_time - 604800))  # 7天 = 7 * 24 * 60 * 60 秒

# 获取最新的文件名
filenameV4=$(curl -s https://publicdata.caida.org/datasets/routing/routeviews-prefix2as/pfx2as-creation.log | tail -n 1 | awk '{print $3}')
downlinkV4="https://publicdata.caida.org/datasets/routing/routeviews-prefix2as/${filenameV4}"

filenameV6=$(curl -s https://publicdata.caida.org/datasets/routing/routeviews6-prefix2as/pfx2as-creation.log | tail -n 1 | awk '{print $3}')
downlinkV6="https://publicdata.caida.org/datasets/routing/routeviews6-prefix2as/${filenameV6}"

# 检查文件是否存在且在7天内
should_download_v4=false
should_download_v6=false

if [ "$IP_VERSION" == "4" ] || [ "$IP_VERSION" == "46" ]; then
    v4_file="$data_dir/${filenameV4}"
    if [ ! -f "$v4_file" ]; then
        should_download_v4=true
    else
        file_time=$(stat -c %Y "$v4_file")
        if [ "$file_time" -lt "$seven_days_ago" ]; then
            should_download_v4=true
        fi
    fi

    if [ "$should_download_v4" = true ]; then
        echo "正在下载IPv4数据文件..."
        wget -O "$v4_file" "$downlinkV4"
        # 清理旧的IPv4数据文件
        find "$data_dir" -type f -name 'pfx2as-*.gz' ! -name "${filenameV4}" -delete
    fi
fi

if [ "$IP_VERSION" == "6" ] || [ "$IP_VERSION" == "46" ]; then
    v6_file="$data_dir/${filenameV6}"
    if [ ! -f "$v6_file" ]; then
        should_download_v6=true
    else
        file_time=$(stat -c %Y "$v6_file")
        if [ "$file_time" -lt "$seven_days_ago" ]; then
            should_download_v6=true
        fi
    fi

    if [ "$should_download_v6" = true ]; then
        echo "正在下载IPv6数据文件..."
        wget -O "$v6_file" "$downlinkV6"
        # 清理旧的IPv6数据文件
        find "$data_dir" -type f -name 'pfx2as-*.gz' ! -name "${filenameV6}" -delete
    fi
fi

output_file="$HOME/$ASN.txt"
> "$output_file"

if [ "$IP_VERSION" == "4" ] || [ "$IP_VERSION" == "46" ]; then
    echo "正在处理AS$ASN的IPv4前缀..."
    zgrep -w "${ASN}" "$data_dir/${filenameV4}" | while read -r line; do
        ip=$(echo "$line" | awk '{print $1}')
        mask=$(echo "$line" | awk '{print $2}')
        echo "${ip}/${mask}" >> "$output_file"
    done
    echo "成功生成AS${ASN}的IPv4前缀！"
fi

if [ "$IP_VERSION" == "6" ] || [ "$IP_VERSION" == "46" ]; then
    echo "正在处理AS$ASN的IPv6前缀..."
    zgrep -w "${ASN}" "$data_dir/${filenameV6}" | while read -r line; do
        ip=$(echo "$line" | awk '{print $1}')
        mask=$(echo "$line" | awk '{print $2}')
        echo "${ip}/${mask}" >> "$output_file"
    done
    echo "成功生成AS${ASN}的IPv6前缀！"
fi

if [ "$IP_VERSION" != "4" ] && [ "$IP_VERSION" != "6" ] && [ "$IP_VERSION" != "46" ]; then
    echo "输入的配置有误！脚本即将退出。"
    exit 1
fi

echo " "
echo "请查看 ~/$ASN.txt"
echo " "
