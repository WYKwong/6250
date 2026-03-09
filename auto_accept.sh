#!/bin/bash
# auto_accept.sh - 一键完成抓包和全量测试流程

# 授予权限
chmod +x *.sh gen_pcap.py 2>/dev/null
./cleanup.sh

echo "========================================"
echo "步骤 1: 自动化生成 packetcapture.pcap"
echo "========================================"
# 运行抓包脚本
sudo python gen_pcap.py

echo -e "\n========================================"
echo "步骤 2: 启动防火墙并运行 86 条标准测试"
echo "========================================"

# 检查测试目录
if [ -d "test-suite/standard" ]; then
    # 同步代码
    cp sdn-firewall.py configure.pol test-suite/standard/
    cd test-suite/standard/

    echo "正在后台启动 POX 防火墙控制器..."
    ./start-firewall.sh configure.pol > fw_log.txt 2>&1 &
    FW_PID=$!

    # 给控制器启动预留时间
    echo "等待控制器就绪 (8s)..."
    sleep 8

    # 运行评分脚本
    echo "开始执行连通性矩阵测试..."
    sudo python test_all.py

    # 任务结束后清理进程
    echo "正在清理测试环境..."
    kill $FW_PID 2>/dev/null
    cd ../..
    ./cleanup.sh
else
    echo "错误: 未找到 test-suite/standard 目录，请确认项目结构。"
fi

echo -e "\n========================================"
echo "所有自动化任务已执行完毕！"
echo "1. 请确认上方测试结果是否为 Passed 86 / 86"
echo "2. 确认根目录下是否生成了 packetcapture.pcap"
echo "========================================"
