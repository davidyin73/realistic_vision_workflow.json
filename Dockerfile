# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# 创建模型目录
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae

# 不需要下载模型，运行时从网络卷/runpod-volume加载
# 工作流中将使用完整路径：/runpod-volume/Realistic_Vision_V6.0_NV_B1.safetensors
