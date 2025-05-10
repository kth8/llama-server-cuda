FROM docker.io/nvidia/cuda:12.0.0-cudnn8-devel-ubuntu22.04 as builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y git cmake build-essential libcurl4-openssl-dev

RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git

RUN cmake llama.cpp -B llama.cpp/build -DGGML_CUDA=ON -DBUILD_SHARED_LIBS=OFF

RUN cmake --build llama.cpp/build --config Release -j 4 --target llama-server

FROM docker.io/nvidia/cuda:12.0.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
     apt install -y libcublas-12-0 libcurl4 libgomp1 && \
     rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/local/nvidia && \
    ln -vs /usr/local/cuda-12.0/targets/x86_64-linux/lib /usr/local/nvidia/lib

COPY --from=builder /llama.cpp/build/bin/llama-server .

RUN ldd /llama-server

ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=8192
ENV LLAMA_ARG_N_PARALLEL=3
ENV LLAMA_ARG_N_GPU_LAYERS=99
ENV LLAMA_ARG_FLASH_ATTN=1
ENV LLAMA_ARG_CACHE_TYPE_K=q8_0
ENV LLAMA_ARG_CACHE_TYPE_V=q8_0

CMD ["/llama-server"]
