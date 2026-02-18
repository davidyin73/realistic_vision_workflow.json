# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
# Could not resolve unknown_registry node 'CheckpointLoaderSimple' (no aux_id) - skipped

# download models into comfyui
RUN comfy model download --url https://huggingface.co/SG161222/Realistic_Vision_V6.0_B1_noVAE/blob/main/Realistic_Vision_V6.0_NV_B1.safetensors --relative-path models/checkpoints --filename Realistic_Vision_V6.0_NV_B1.safetensors
RUN comfy model download --url https://huggingface.co/JCTN/Juggernaut/blob/main/realisticVisionV60B1_v51HyperVAE.safetensors --relative-path models/vae --filename realisticVisionV60B1_v51HyperVAE.safetensors

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
