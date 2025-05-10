# llama.cpp CUDA Server Container Image

This repository provides a ready-to-use container image with the `llama.cpp` server, compiled with CUDA 12 support to enable GPU-accelerated inference. Requires CPU with AVX2 support and Nvidia driver/[Container Toolkit](https://podman-desktop.io/docs/podman/gpu) preconfigured.

[Multimodal](https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal.md)

[LLaMA.cpp HTTP Server](https://github.com/ggml-org/llama.cpp/tree/master/tools/server)
```
docker container run \
    --detach \
    --init \
    --restart always \
    --device nvidia.com/gpu=all \
    --publish 8080:8080 \
    --volume llama:/root/.cache \
    --label io.containers.autoupdate=registry \
    --pull newer \
    --name llama-cuda \
    --env LLAMA_ARG_HF_REPO=ggml-org/Qwen2.5-VL-3B-Instruct-GGUF \
    ghcr.io/kth8/llama-server-cuda:latest
```
Replace `ggml-org/Qwen2.5-VL-3B-Instruct-GGUF` with your model of choice from [Hugging Face](https://huggingface.co/). Verify if the server is running by going to http://127.0.0.1:8080 in your web browser or using the terminal:
```
uv run test_inference.py
```
