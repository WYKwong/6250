#!/bin/bash
# auto_accept.sh - 一键完成抓包和测试流程
# 注意：必须在项目根目录运行，需要 sudo 权限

set -e

PROJECT_DIR="$(pwd)"

# 授予权限
chmod +x *.sh 2>/dev/null
chmod +x test-suite/standard/*.sh 2>/dev/null

echo "========================================"
echo "步骤 0: 清理环境"
echo "========================================"
# 仅清理 mininet 和 pox，不使用通用的 killall python 避免自杀
sudo mn -c > /dev/null 2>&1 || true
sudo pkill -9 pox || true

echo "========================================"
echo "步骤 1: 自动化生成 packetcapture.pcap"
echo "========================================"
sudo python3 gen_pcap.py
echo ""

echo "========================================"
echo "步骤 2: 准备 Standard 测试"
echo "========================================"

# 先清理残余进程
./cleanup.sh 2>/dev/null || true
sudo mn -c > /dev/null 2>&1 || true
sleep 2

# 把代码同步到测试目录
cp sdn-firewall.py test-suite/standard/
cp configure.pol test-suite/standard/
cp setup-firewall.py test-suite/standard/

cd test-suite/standard

# 确保 POX firewall 目录存在
if [ ! -d ~/pox/pox/firewall ]; then
  mkdir -p ~/pox/pox/firewall
fi

# 手动把文件拷到 POX 目录（和 start-firewall.sh 做的一样）
cp configure.pol ~/pox/pox/firewall/config.pol
cp sdn-firewall.py ~/pox/pox/firewall/sdnfirewall.py
cp setup-firewall.py ~/pox/pox/firewall/setupfirewall.py

echo "正在启动 POX 防火墙控制器 (后台)..."

# 直接调用 pox.py，而不是通过 start-firewall.sh
cd ~/pox
python pox.py openflow.of_01 forwarding.l2_learning firewall.setupfirewall > /tmp/pox_log.txt 2>&1 &
POX_PID=$!
cd "$PROJECT_DIR/test-suite/standard"

# 等待 POX 控制器完全启动，检查端口 6633
echo -n "等待控制器启动"
for i in $(seq 1 20); do
    if ss -tln | grep -q ':6633'; then
        echo " -> 就绪!"
        break
    fi
    echo -n "."
    sleep 1
done

# 再检查一次
if ! ss -tln | grep -q ':6633'; then
    echo ""
    echo "警告: 控制器可能未在端口 6633 启动，查看日志:"
    cat /tmp/pox_log.txt
    echo ""
    echo "仍然尝试运行测试..."
fi

echo ""
echo "========================================"
echo "步骤 3: 运行 86 条标准测试"
echo "========================================"
sudo python test_all.py

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
echo "所有自动化任务已执行完毕！"
echo "1. 请确认测试结果是否为 Passed 86 / 86"
echo "2. 确认根目录下是否有 packetcapture.pcap"
echo ""
echo "打包提交命令:"
echo "  zip gtlogin_sdn.zip packetcapture.pcap configure.pol sdn-firewall.py"
echo "========================================"
