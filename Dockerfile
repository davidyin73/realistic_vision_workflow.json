# 复制配置文件
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
ENV EXTRA_MODEL_PATHS=/comfyui/extra_model_paths.yaml

# 复制启动脚本
COPY start_with_proxy.sh /workspace/start_with_proxy.sh
RUN chmod +x /workspace/start_with_proxy.sh

# 修改启动命令
CMD ["/bin/bash", "/workspace/start_with_proxy.sh"]
