FROM runpod/worker-comfyui:5.5.1-base
RUN apt-get update && apt-get install -y curl
WORKDIR /workspace
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
ENV EXTRA_MODEL_PATHS=/comfyui/extra_model_paths.yaml
COPY start_with_proxy.sh /workspace/start_with_proxy.sh
RUN chmod +x /workspace/start_with_proxy.sh
CMD ["/bin/bash", "/workspace/start_with_proxy.sh"]
