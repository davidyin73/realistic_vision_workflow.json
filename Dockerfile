# 🎯 灵创AI一体机 - 永久性Docker配置
# 支持6大行业模型，一次配置永久使用

# 基础镜像：RunPod官方ComfyUI worker
FROM runpod/worker-comfyui:5.5.1-base

# 创建标准化目录结构
RUN mkdir -p \
    /comfyui/models/checkpoints \
    /comfyui/models/vae \
    /comfyui/models/loras \
    /comfyui/models/embeddings

# 复制配置文件
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# 验证配置文件
RUN echo "==========================================" && \
    echo "🔧 灵创AI一体机配置验证" && \
    echo "==========================================" && \
    echo "1. 验证extra_model_paths.yaml:" && \
    cat /comfyui/extra_model_paths.yaml && \
    echo "" && \
    echo "2. 验证目录权限:" && \
    ls -la /comfyui/extra_model_paths.yaml && \
    echo "==========================================" && \
    echo "✅ 配置验证完成" && \
    echo "=========================================="

# 启动ComfyUI worker
CMD ["python", "/handler.py"]
