# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# 创建模型目录（模型从网络卷加载，不下载）
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae

# 工作流中使用完整路径：/runpod-volume/Realistic_Vision_V6.0_NV_B1.safetensors
