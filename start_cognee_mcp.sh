#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# 参数检查
# -------------------------------
if [ -z "${1:-}" ]; then
    echo "用法: $0 /path/to/project_directory"
    exit 1
fi

PROJECT_DIR="$1"
PERSIST_DIR="$PROJECT_DIR/.cognee_store"
mkdir -p "$PERSIST_DIR"

# -------------------------------
# 禁用所有代理
# -------------------------------
unset HTTP_PROXY http_proxy HTTPS_PROXY https_proxy ALL_PROXY all_proxy NO_PROXY no_proxy

# -------------------------------
# MCP 镜像
# -------------------------------
MCP_IMAGE="cognee/cognee-mcp:main"

# -------------------------------
# 随机端口生成（1025~65535）
# -------------------------------
get_random_port() {
    while :; do
        PORT=$((RANDOM % 64511 + 1025))
        # 检查端口是否被占用
        if ! lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
            echo "$PORT"
            return
        fi
    done
}

RANDOM_PORT=$(get_random_port)

# -------------------------------
# 容器名（包含随机端口，保证唯一）
# -------------------------------
PROJECT_NAME=$(basename "$PROJECT_DIR")
CONTAINER_NAME="cognee_mcp_${PROJECT_NAME}_${RANDOM_PORT}"
MCP_NAME="cognee_mcp_${PROJECT_NAME}_${RANDOM_PORT}"

# -------------------------------
# 如果旧容器存在，先停止并删除
# -------------------------------
if docker ps -a --format '{{.Names}}' | grep -x "$CONTAINER_NAME" >/dev/null; then
    echo "检测到旧容器 $CONTAINER_NAME，正在停止并删除..."
    docker stop "$CONTAINER_NAME" >/dev/null || true
    docker rm "$CONTAINER_NAME" >/dev/null || true
fi

# -------------------------------
# 检查镜像是否存在，否则拉取
# -------------------------------
if ! docker image inspect "$MCP_IMAGE" >/dev/null 2>&1; then
    echo "拉取 cognee-mcp 镜像..."
    docker pull "$MCP_IMAGE"
fi

# -------------------------------
# 启动 MCP Docker 容器
# -------------------------------
echo "启动 Cognee MCP 服务 ..."
docker run -d --rm \
    --name "$CONTAINER_NAME" \
    -v "$PROJECT_DIR":/workspace/code \
    -v "$PERSIST_DIR":/workspace/persist \
    -e TRANSPORT_MODE=http \
    -p "$RANDOM_PORT":8000 \
    "$MCP_IMAGE"

# -------------------------------
# 输出信息
# -------------------------------
cat <<EOF

==================== Cognee MCP 服务信息 ====================
项目目录: $PROJECT_DIR
持久化目录: $PERSIST_DIR
Cognee MCP 随机端口: $RANDOM_PORT
Cognee MCP 容器名: $CONTAINER_NAME
Cognee MCP 名称（Gemini CLI 唯一标识）: $MCP_NAME

Gemini CLI 加载该 Cognee MCP 作为项目持久记忆:
  cd $PROJECT_DIR && gemini mcp add $MCP_NAME http://127.0.0.1:$RANDOM_PORT/mcp --transport http

退出 Cognee MCP 服务:
  docker stop $CONTAINER_NAME
=====================================================

EOF
