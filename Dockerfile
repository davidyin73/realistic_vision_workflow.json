# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae
