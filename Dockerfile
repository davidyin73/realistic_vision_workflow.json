FROM runpod/worker-comfyui:5.5.1-base

# 设置环境变量
ENV EXTRA_MODEL_PATHS=/comfyui/extra_model_paths.yaml
ENV NETWORK_VOLUME_DEBUG=true
ENV PYTHONUNBUFFERED=1

# 创建必要的目录
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae
RUN mkdir -p /runpod-volume/checkpoints /runpod-volume/vae

# 复制配置文件
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# 验证配置存在
RUN test -f /comfyui/extra_model_paths.yaml && echo "✅ extra_model_paths.yaml found" || echo "❌ ERROR: extra_model_paths.yaml missing"

# 启动命令
CMD ["python", "/handler.py"]
