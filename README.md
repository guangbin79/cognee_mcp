# Cognee MCP 使用说明

Cognee MCP 就是给 LLM 挂一块“知识硬盘”，让它既能记住更多，又能查得更准，还能避免 token 浪费，减少上下文污染，降低幻觉。

### 启动 MCP 服务

使用 `start_cognee_mcp.sh` 针对具体项目启动 Cognee MCP 服务，随机分配端口，同时自动更新持久化记忆：

```bash
bash start_cognee_mcp.sh <项目目录>
```

### 示例输出：

```
> bash start_cognee_mcp.sh ~/Documents/TestProject
启动 Cognee MCP 服务 ...
3a6b322dfacc0b410acf23cbb6a0051f02a9f1d31a2b0637b693de4503b78502

==================== Cognee MCP 服务信息 ====================
项目目录: /home/guangbin/Documents/TestProject
持久化目录: /home/guangbin/Documents/TestProject/.cognee_store
Cognee MCP 随机端口: 33775
Cognee MCP 容器名: cognee_mcp_TestProject_33775
Cognee MCP 名称（Gemini CLI 唯一标识）: cognee_mcp_TestProject_33775

Gemini CLI 加载该 Cognee MCP 作为项目持久记忆:
  cd /home/guangbin/Documents/TestProject && gemini mcp add TestProject_33775 http://127.0.0.1:33775/mcp --transport http

退出 Cognee MCP 服务:
  docker stop cognee_mcp_TestProject_33775
=====================================================
```

### 功能特点

* **随机端口**：每次启动 MCP 服务自动选择一个未占用的端口，无需用户手动指定。
* **自动增量索引**：监听文件修改、新增和删除，自动更新持久化记忆。
* **Gemini CLI 集成**：输出命令示例，可直接在 Gemini CLI 加载 MCP 服务。
* **退出命令**：提供完整退出命令，方便停止 MCP 服务。

### 注意事项

* 确保已安装系统依赖：`docker`，支持从docker hub拉取镜像
* 每个项目的持久化目录为 `<项目目录>/.cognee_store`，独立存储 embeddings 和记忆数据。
* Gemini CLI 临时加载命令可直接复制执行，不影响其他 MCP 服务实例。

