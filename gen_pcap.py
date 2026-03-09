#!/usr/bin/python3
# gen_pcap.py - 自动执行 Part 3 抓包流程
import time
import os
import sys

def run_capture():
    py_cmd = "python3"
    
    # 动态导入处理连字符文件名 ws-topology.py
    sys.path.append('.')
    try:
        ws_topo = __import__('ws-topology')
        FirewallTopo = ws_topo.FirewallTopo
    except ImportError:
        print("错误: 找不到 ws-topology.py")
        return

    from mininet.net import Mininet
    from mininet.link import TCLink

    print("--- 启动抓包拓扑并开始 Tshark ---")
    topo = FirewallTopo()
    # 抓包拓扑不需要外部控制器
    net = Mininet(topo=topo, link=TCLink, controller=None)
    
    try:
        net.start()
        
        us1 = net.get('us1')
        us2 = net.get('us2')
        
        pcap_path = "/tmp/packetcapture.pcap"
        print("启动 tshark (禁用域名解析)...")
        # 使用 -n 禁用域名解析，避免请求外网导致卡死
        us1.cmd('tshark -n -w %s > /dev/null 2>&1 &' % pcap_path)
        time.sleep(3)
        
        print("--- 执行 PingAll 建立网络连接 (ARP) ---")
        net.pingAll()
        
        print("--- 模拟流量: ICMP (Ping) ---")
        us1.cmd('ping -c 2 10.0.1.2')
        us2.cmd('ping -c 2 10.0.1.1')
        
        print("--- 模拟流量: TCP (Port 80) ---")
        # us1 启动监听
        us1.cmd('sudo %s test-server.py T 10.0.1.1 80 > /dev/null 2>&1 &' % py_cmd)
        time.sleep(2)
        # us2 发起请求，增加 timeout 避免卡死
        us2.cmd('timeout 5 sudo %s test-client.py T 10.0.1.1 80 > /dev/null 2>&1' % py_cmd)
        us1.cmd('sudo pkill -f test-server.py')
        
        print("--- 模拟流量: UDP (Port 8000) ---")
        # us1 启动监听
        us1.cmd('sudo %s test-server.py U 10.0.1.1 8000 > /dev/null 2>&1 &' % py_cmd)
        time.sleep(2)
        print("发送 UDP 数据中...")
        # us2 发起请求，增加 timeout 避免卡死
        us2.cmd('timeout 5 sudo %s test-client.py U 10.0.1.1 8000 > /dev/null 2>&1' % py_cmd)
        print("清理 UDP 服务端...")
        us1.cmd('sudo pkill -f test-server.py')
        
        print("--- 停止抓包并保存文件 ---")
        os.system('sudo pkill -9 tshark')
        time.sleep(1)
        
    finally:
        print("正在停止 Mininet...")
        net.stop()
    
    # 修正权限并提取文件
    os.system('sudo chown mininet:mininet %s 2>/dev/null || true' % pcap_path)
    os.system('cp %s . 2>/dev/null || true' % pcap_path)
    print("--- 任务结束: packetcapture.pcap 已在当前目录生成 ---")

if __name__ == '__main__':
    run_capture()
