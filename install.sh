#!/bin/bash

echo -e "\n🔍 正在扫描本机开放端口...\n"

# 获取所有监听 TCP 端口
PORTS=$(ss -tln | awk 'NR>1 {print $4}' | grep -oE '[0-9]+$' | sort -n | uniq)

echo -e "📡 尝试检测哪些端口提供 HTTP / HTTPS 网页服务...\n"

for port in $PORTS; do
  for proto in http https; do
    echo -e "🔗 检测 ${proto}://127.0.0.1:$port"

    if [ "$proto" = "https" ]; then
      RESPONSE=$(curl -k --max-time 3 -s https://127.0.0.1:$port)
    else
      RESPONSE=$(curl --max-time 3 -s http://127.0.0.1:$port)
    fi

    TITLE=$(echo "$RESPONSE" | grep -i -o '<title>.*</title>' | sed 's/<\/\?title>//gi')

    if [[ -n "$TITLE" ]]; then
      echo -e "✅ [$proto] 端口 $port 返回网页标题：$TITLE"
    elif [[ -n "$RESPONSE" ]]; then
      echo -e "✅ [$proto] 端口 $port 返回网页内容，但无标题。"
    else
      echo -e "❌ [$proto] 端口 $port 无网页响应。\n"
    fi

    echo "------------------------------------"
  done
done
