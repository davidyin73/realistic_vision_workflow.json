# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# 从网络卷复制模型（而不是从HuggingFace下载）
# 注意：Serverless端点网络卷挂载路径是 /runpod-volume
# 需要先确保网络卷z45mpn2cdn正确挂载

# 创建必要目录
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae

# 从网络卷复制模型文件（路径需要确认）
# 假设模型在 /runpod-volume/ 目录下
COPY --from=runpod-volume /runpod-volume/Realistic_Vision_V6.0_NV_B1.safetensors /comfyui/models/checkpoints/
COPY --from=runpod-volume /runpod-volume/realisticVisionV60B1_v51HyperVAE.safetensors /comfyui/models/vae/

# 或者使用RUN命令复制（如果网络卷已经挂载）
# RUN cp /runpod-volume/Realistic_Vision_V6.0_NV_B1.safetensors /comfyui/models/checkpoints/
# RUN cp /runpod-volume/realisticVisionV60B1_v51HyperVAE.safetensors /comfyui/models/vae/
