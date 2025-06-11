#!/bin/bash

echo -e "\n🔍 正在扫描本机开放端口...\n"

PORTS=$(ss -tln | awk 'NR>1 {print $4}' | grep -oE '[0-9]+$' | sort -n | uniq)

echo -e "📡 正在检测有效的 HTTP / HTTPS 网页服务...\n"

COUNT=0

for port in $PORTS; do
  for proto in http https; do
    if [ "$proto" = "https" ]; then
      RESPONSE=$(curl -k --max-time 3 -s https://127.0.0.1:$port)
    else
      RESPONSE=$(curl --max-time 3 -s http://127.0.0.1:$port)
    fi

    TITLE=$(echo "$RESPONSE" | grep -i -o '<title>.*</title>' | sed 's/<\/\?title>//gi')

    if [[ -n "$TITLE" ]]; then
      echo -e "✅ [$proto] 端口 $port 返回网页标题：$TITLE"
      ((COUNT++))
      echo "------------------------------------"
    elif [[ -n "$RESPONSE" ]]; then
      echo -e "✅ [$proto] 端口 $port 返回网页内容，但无标题。"
      ((COUNT++))
      echo "------------------------------------"
    fi
  done
done

echo -e "\n📊 检测汇总：共发现 $COUNT 个有效网页端口"
echo -e "✅ 感谢使用 check-web-ports！"
