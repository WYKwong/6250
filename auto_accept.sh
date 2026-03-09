#!/bin/bash
# auto_accept.sh - 一键完成抓包和测试流程
# 注意：必须在项目根目录运行，需要 sudo 权限

set -e

PROJECT_DIR="$(pwd)"

# 确保 tshark 已安装
if ! command -v tshark &> /dev/null; then
    echo "未检测到 tshark，尝试自动安装..."
    sudo apt-get update && sudo apt-get install -y tshark
fi

# 授予权限
chmod +x *.sh 2>/dev/null
chmod +x test-suite/standard/*.sh 2>/dev/null

echo "========================================"
echo "步骤 0: 清理环境"
echo "========================================"
# 仅清理 mininet 和 pox，不使用通用的 killall python 避免自杀
sudo mn -c > /dev/null 2>&1 || true
sudo pkill -9 pox || sudo pkill -9 python3 || true
sleep 2

echo "========================================"
echo "步骤 1: 自动化生成 packetcapture.pcap"
echo "========================================"
sudo python3 gen_pcap.py
echo ""

echo "========================================"
echo "步骤 2: 准备 Standard 测试阶段"
echo "========================================"

# 把代码同步到测试目录
cp sdn-firewall.py test-suite/standard/
cp configure.pol test-suite/standard/
cp setup-firewall.py test-suite/standard/

cd test-suite/standard

# 确保 POX firewall 目录存在
if [ ! -d ~/pox/pox/firewall ]; then
  mkdir -p ~/pox/pox/firewall
fi

# 同步文件到 POX 系统目录
cp configure.pol ~/pox/pox/firewall/config.pol
cp sdn-firewall.py ~/pox/pox/firewall/sdnfirewall.py
cp setup-firewall.py ~/pox/pox/firewall/setupfirewall.py

echo "正在后台启动 POX 控制器..."
cd ~/pox
# 显式使用 python3
python3 pox.py openflow.of_01 forwarding.l2_learning firewall.setupfirewall > /tmp/pox_log.txt 2>&1 &
POX_PID=$!
cd "$PROJECT_DIR/test-suite/standard"

# 轮询探测控制器是否就绪
echo -n "等待控制器监听 6633 端口"
READY=0
for i in $(seq 1 30); do
    if ss -tln | grep -q ':6633'; then
        echo " -> 就绪!"
        READY=1
        break
    fi
    echo -n "."
    sleep 1
done

if [ $READY -eq 0 ]; then
    echo ""
    echo "严重错误: POX 控制器未能成功启动。最后几行日志:"
    tail -n 20 /tmp/pox_log.txt
    kill $POX_PID 2>/dev/null || true
    exit 1
fi

echo ""
echo "========================================"
echo "步骤 3: 运行 86 条标准验收测试"
echo "========================================"
# 同步使用 python3
sudo python3 test_all.py

echo ""
echo "========================================"
echo "步骤 4: 清理环境"
echo "========================================" # 任务结束后清理进程
echo "正在清理测试环境..."
kill $POX_PID 2>/dev/null || true
cd "$PROJECT_DIR"
sudo mn -c > /dev/null 2>&1 || true
sudo pkill -9 pox || true

echo ""
echo "========================================"
echo "所有自动化任务已完成！"
echo "1. 检查上方 Passed 是否为 86 / 86"
if [ -f "packetcapture.pcap" ]; then
    echo "2. 已成功生成 packetcapture.pcap"
else
    echo "2. 警告: 未发现 packetcapture.pcap，请检查步骤 1 日志"
fi
echo ""
echo "打包提交命令:"
echo "  zip gtlogin_sdn.zip packetcapture.pcap configure.pol sdn-firewall.py"
echo "========================================"
