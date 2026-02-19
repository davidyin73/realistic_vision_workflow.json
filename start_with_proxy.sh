#!/bin/bash
# RunPod Serverless ComfyUI启动脚本（带代理）
# 解决网络隔离问题：RunPod worker容器无法直接连接ComfyUI容器

set -e  # 出错时退出

echo "========================================"
echo "🚀 灵创AI一体机 - ComfyUI Serverless启动"
echo "========================================"
echo "时间: $(date)"
echo "工作目录: $(pwd)"

# 配置文件路径
CONFIG_FILE="/comfyui/extra_model_paths.yaml"
COMFYUI_DIR="/workspace/runpod-slim/ComfyUI"
LOG_FILE="/workspace/comfyui_startup.log"

# 检查配置文件
echo "📁 检查配置文件..."
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    echo "确保extra_model_paths.yaml已正确复制到容器"
    exit 1
fi
echo "✅ 配置文件存在: $CONFIG_FILE"

# 检查ComfyUI目录
echo "📁 检查ComfyUI目录..."
if [ ! -d "$COMFYUI_DIR" ]; then
    echo "❌ ComfyUI目录不存在: $COMFYUI_DIR"
    exit 1
fi
echo "✅ ComfyUI目录存在: $COMFYUI_DIR"

# 启动ComfyUI（监听容器IP）
echo "🚀 启动ComfyUI服务..."
cd "$COMFYUI_DIR"
echo "ComfyUI监听地址: 172.20.0.2:8188"
echo "启动日志: $LOG_FILE"

# 在后台启动ComfyUI
python3 main.py --listen 172.20.0.2 --port 8188 > "$LOG_FILE" 2>&1 &
COMFY_PID=$!
echo "ComfyUI进程PID: $COMFY_PID"

# 等待ComfyUI启动
echo "⏳ 等待ComfyUI启动（15秒）..."
for i in {1..30}; do
    if curl -s http://172.20.0.2:8188/ >/dev/null 2>&1; then
        echo "✅ ComfyUI已启动并运行正常"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ ComfyUI启动超时"
        echo "查看启动日志:"
        tail -20 "$LOG_FILE"
        exit 1
    fi
    sleep 1
done

# 检查模型路径配置
echo "🔧 检查模型路径..."
sleep 2
echo "启动日志片段:"
grep -i "model\|path\|checkpoint\|vae" "$LOG_FILE" | tail -5 || true

# 启动代理服务（供RunPod worker连接）
echo "🔀 启动代理服务..."
echo "代理配置: 127.0.0.1:8188 → 172.20.0.2:8188"
echo "RunPod worker将连接127.0.0.1:8188"

cat > /tmp/runpod_worker_proxy.py << 'PROXY_EOF'
#!/usr/bin/env python3
"""
RunPod worker代理服务
将worker的请求从127.0.0.1:8188转发到ComfyUI容器172.20.0.2:8188
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import http.client
import logging
import sys

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('RunPodProxy')

# ComfyUI容器地址
COMFYUI_HOST = "172.20.0.2"
COMFYUI_PORT = 8188
TIMEOUT = 30

class RunPodProxyHandler(BaseHTTPRequestHandler):
    """处理RunPod worker的HTTP请求"""
    
    def do_POST(self):
        """处理POST请求（工作流执行）"""
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length) if content_length > 0 else None
            
            logger.info(f"📨 收到请求: {self.path}, 长度: {content_length}字节")
            
            # 转发到ComfyUI
            conn = http.client.HTTPConnection(COMFYUI_HOST, COMFYUI_PORT, timeout=TIMEOUT)
            conn.request("POST", self.path, body, dict(self.headers))
            resp = conn.getresponse()
            
            # 返回响应
            self.send_response(resp.status)
            for key, value in resp.getheaders():
                self.send_header(key, value)
            self.end_headers()
            self.wfile.write(resp.read())
            
            logger.info(f"✅ 请求完成: {self.path}, 状态: {resp.status}")
            
        except Exception as e:
            logger.error(f"❌ 代理错误: {str(e)}")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Proxy error: {str(e)}".encode())
    
    def do_GET(self):
        """处理GET请求（健康检查）"""
        try:
            conn = http.client.HTTPConnection(COMFYUI_HOST, COMFYUI_PORT, timeout=TIMEOUT)
            conn.request("GET", self.path, None, dict(self.headers))
            resp = conn.getresponse()
            
            self.send_response(resp.status)
            for key, value in resp.getheaders():
                self.send_header(key, value)
            self.end_headers()
            self.wfile.write(resp.read())
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Health check failed: {str(e)}".encode())

def main():
    """启动代理服务器"""
    server_address = ('127.0.0.1', 8188)
    httpd = HTTPServer(server_address, RunPodProxyHandler)
    
    logger.info("========================================")
    logger.info("🚀 RunPod worker代理服务已启动")
    logger.info(f"   监听: {server_address[0]}:{server_address[1]}")
    logger.info(f"   转发: {COMFYUI_HOST}:{COMFYUI_PORT}")
    logger.info("========================================")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("👋 代理服务停止")
        sys.exit(0)

if __name__ == "__main__":
    main()
PROXY_EOF

# 启动代理
python3 /tmp/runpod_worker_proxy.py &
PROXY_PID=$!
echo "代理进程PID: $PROXY_PID"

# 验证代理运行
sleep 3
if curl -s http://127.0.0.1:8188/ >/dev/null 2>&1; then
    echo "✅ 代理服务运行正常"
else
    echo "❌ 代理服务启动失败"
    exit 1
fi

echo "========================================"
echo "🎉 启动完成！"
echo "----------------------------------------"
echo "🔗 ComfyUI地址: http://172.20.0.2:8188"
echo "🔗 Worker代理地址: http://127.0.0.1:8188"
echo "📊 ComfyUI日志: $LOG_FILE"
echo "🔄 进程PID: ComfyUI=$COMFY_PID, 代理=$PROXY_PID"
echo "========================================"

# 保持脚本运行，监控进程
echo "👀 监控进程状态..."
while true; do
    if ! kill -0 $COMFY_PID 2>/dev/null; then
        echo "❌ ComfyUI进程已停止"
        break
    fi
    if ! kill -0 $PROXY_PID 2>/dev/null; then
        echo "❌ 代理进程已停止"
        break
    fi
    sleep 10
done

echo "💥 服务异常停止，退出..."
exit 1