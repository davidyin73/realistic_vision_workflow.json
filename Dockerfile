FROM runpod/worker-comfyui:5.5.1-base
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/vae
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
CMD ["python", "/handler.py"]
