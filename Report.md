# SDN Firewall 项目全面规划与分析报告

## 1. 项目整体概述

本项目为 Georgia Tech CS 6250 (Computer Networks) 秋季学期的实验项目（SDN Firewall Project with POX）。本项目的核心任务是在软件定义网络（SDN）框架下，利用 POX 控制器和 OpenFlow 协议，实现一个动态的、基于策略的底层网络防火墙。所有网络拓扑基于 Mininet 进行仿真。

---

## 2. 项目目录结构

通过对项目根目录及 `test-suite` 目录的扫描，项目的核心结构如下：

- **核心执行文件:**
  - `sdn-firewall.py`: **本项目的核心开发文件**。你需要在此文件内的 `firewall_policy_processing` 函数中编写代码。负责将解析后的策略字典列表转换为 POX/OpenFlow 可以识别的 Match 和 Action 操作（flow_mods）。
  - `setup-firewall.py`: 无需修改的设置文件，负责读取 `configure.pol` 文件并校验 IP、MAC 地址、端口格式，将格式化好的策略传给 `sdn-firewall.py` 并对接 POX 事件系统。
  - `configure.pol`: 防火墙规则配置文件，规则的定义来源（格式为：`RuleNumber,Action,Source MAC,Destination MAC,Source IP,Destination IP,Protocol,Source Port,Destination Port,Comment`）。

- **网络与环境仿真:**
  - `sdn-topology.py`: 基于 Mininet 的网络拓扑定义文件，包含全球多个分支网络（ Headquarters `hq`, US `us`, India `in`, China `cn`, UK `uk` 等）。通过这个文件可以在本地构建测试集群。
  - `start-firewall.sh` & `start-topology.sh`: 用于启动防火墙控制器以及网络拓扑环境的快捷 Bash 脚本。
  - `cleanup.sh`: 清理 Mininet 遗留状态的脚本。

- **测试与验证通信机制:**
  - `test-client.py`: 建立 TCP/UDP 会话或测试连通性的客户端脚本。
  - `test-server.py`: 在指定端口监听 TCP/UDP 连接请求并回传数据的服务端脚本。

- **测试套房 (`test-suite/standard/`):**
  - 含有一系列用于自动评分的脚本。
  - `test_all.py`: 高度自动化的端到端测试工具，会自动读取特定用例并在 Mininet 中自动模拟 Client/Server 通信。
  - `testcases.txt`: 由上百条测试数据组成的预设测试用例，包含源目的主机、协议、端口和预期结果（True/False，表示连通或被阻断）。

---

## 3. 内容与实现原理

本项目基于 OpenFlow 下发流表（Flow Table）的概念拦截和放行流量，具体原理如下：
1. **策略解析阶段**: `setup-firewall.py` 通过 Python `csv` 读取 `configure.pol` 的规则，拆分网段（如 `10.0.0.1/32`），校验 MAC, IP 的合法性。
2. **防火墙处理阶段**: 调用 `sdn-firewall.py`，遍历所有的 Rules。开发者的任务是使用 POX API (比如 `of.ofp_flow_mod()`, `of.ofp_match()`) 实现准确的封包匹配，并且注意：**Allow 规则的优先级必须高于 Block 规则**。
3. **下发流表阶段**: 返回的所有 Flow Mods 会被 `setup-firewall.py` 中注册的 Event 监视器捕获并 send 给 Switch 节点（`event.connection.send(rule)`）。

---

## 4. 核心开发目标与要求

1. **动态解析而非硬编码**: 绝对不能在此代码中硬编码 IP 地址、MAC、协议或端口。必须动态地使用 `policy['field']` 提供的值来实现。
2. **支持匹配规则构建**: 利用 POX 的 `ofp_match` 构建基于 IP (网络掩码需正确支持)、TCP/UDP 端口、MAC 的匹配器。
3. **优先级与行为 (Action) 设置**: 
   - 对于 **Allow** (允许)，通常需要赋予高优先级，并且允许数据包沿标准路径发送（或定义为 NORMAL）。
   - 对于 **Block** (拦截)，可能无需下发输出动作（丢弃数据包），优先级基于冲突判定。
4. **无需构建复杂的额外函数**: 整个项目的目标是学会 OpenFlow 控制平面和流表规则的映射算法，要求在 `firewall_policy_processing` 里就可以完成整个流程。

---

## 5. 验收标准与测试流程 (Acceptance & Testing)

本项目的验收完全基于网络包的真实投递状况，不包含单元测试形式的代码检查，而是黑盒连通性测试。

### 5.1 本地测试方法
1. 使用 `./start-firewall.sh` 开启控制器。
2. 使用 `./start-topology.sh` 开启 Mininet，会打开 Mininet CLI 界面。
3. 可手动用 Mininet CLI 命令，例如 `us1 python test-server.py T 10.0.1.1 80 &`，然后在 `cn1` 主机上触发测试：`cn1 python test-client.py T 10.0.1.1 80`。

### 5.2 整体通关验收 (Automated Grading)
项目的最终验收以通过 `test-suite/standard/test_all.py` 为准。
- 执行该脚本会自动创建网络环境控制器，按 `testcases.txt` 载入一系列矩阵条件：
  ```text
  # 示例规则：客户端 服务端 协议 端口 源端口 预期是否联通
  cn3 other1 T 99 80 False
  us1 cn3 T 198 90 True
  ```
- 脚本会调用 Mininet 并自动执行 Ping (`ICMP`), `TCP`, `UDP` 数据包通信。
- 判断标准：如果数据包被成功送达并在 CLI 中被验证 (Received 或是 icmp_seq 出现在返回数据中)，记为 `True`，否则记为 `False`。
- 只有你的 OpenFlow Match 与优先级配置正确实现了拦截和放行，测试连通结果才会完美契合 `testcases.txt` 中预定义的所有 `True`/`False`。
- **验证手段**: 运行测试套件时屏幕上打出 `Passed 86 / 86`（假设总共 86 个测试例）即代表核心逻辑构建成功无误。

### 5.3 注意点与易错点
* **CIDR 匹配处理**: POX 对 IP 地址匹配有限制，文档特别指出 `不要用 IPAddr() 包裹 CIDR 地址`。
* **优先级问题**: “允许(Allow)”的优先级必须压制“阻止(Block)”，必须注意 POX 中流表的 priority 参数。
* **Python 3 适配**: 当前分支采用的是 gar-experimental POX，完全基于 Python 3 ，应当使用 Python 3 语法以及编码方式。
