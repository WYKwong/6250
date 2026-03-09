#!/usr/bin/python
# gen_pcap.py - 自动执行 Part 3 抓包流程
import time
import os
from mininet.net import Mininet
from mininet.link import TCLink

def run_capture():
    print("--- 正在清理旧环境 ---")
    os.system("./cleanup.sh > /dev/null 2>&1")
    
    print("--- 启动抓包拓扑并开始 Tshark ---")
    # 动态导入处理连字符文件名 ws-topology.py
    import sys
    sys.path.append('.')
    try:
        ws_topo = __import__('ws-topology')
        FirewallTopo = ws_topo.FirewallTopo
    except ImportError:
        print("错误: 找不到 ws-topology.py")
        return

    topo = FirewallTopo()
    # 抓包拓扑不需要外部控制器
    net = Mininet(topo=topo, link=TCLink, controller=None)
    net.start()
    
    us1 = net.get('us1')
    us2 = net.get('us2')
    
    # 在 us1 启动后台抓包
    pcap_path = "/tmp/packetcapture.pcap"
    print("启动 tshark...")
    us1.cmd('tshark -w %s &' % pcap_path)
    time.sleep(2)
    
    print("--- 模拟流量: ICMP (Ping) ---")
    us1.cmd('ping -c 3 10.0.1.2')
    us2.cmd('ping -c 3 10.0.1.1')
    
    print("--- 模拟流量: TCP (Server Port 80) ---")
    # us1 作为服务端
    us1.cmd('python test-server.py T 10.0.1.1 80 &')
    time.sleep(2)
    # us2 作为客户端访问 us1
    us2.cmd('python test-client.py T 10.0.1.1 80')
    us1.cmd('pkill -f test-server.py')
    
    print("--- 模拟流量: UDP (Server Port 8000) ---")
    us1.cmd('python test-server.py U 10.0.1.1 8000 &')
    time.sleep(2)
    us2.cmd('python test-client.py U 10.0.1.1 8000')
    us1.cmd('pkill -f test-server.py')
    
    print("--- 停止抓包并停止 Mininet ---")
    os.system('pkill -f tshark')
    time.sleep(1)
    net.stop()
    
    # 修正权限并提取文件
    os.system('sudo chown mininet:mininet %s' % pcap_path)
    os.system('cp %s .' % pcap_path)
    print("--- 抓包完成: packetcapture.pcap 已在当前目录生成 ---")

if __name__ == '__main__':
    run_capture()
