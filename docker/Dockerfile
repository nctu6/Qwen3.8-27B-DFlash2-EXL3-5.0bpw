# syntax=docker/dockerfile:1.7
# Build (on GB10), separate from compose run:
#   cd /home/altos/Qwen3.8-27B-DFlash2-EXL3-5.0bpw
#   docker build -f docker/Dockerfile -t nctu6/qwen38-27b-exl3:latest .
#
# Mirrors kit start.sh: venv + torch(cu130) + MiaAI-Lab/exllamav3 + server deps.
# Weights are NOT baked in — mount via /home/altos/service/Qwen3.8-27B/exl3.yml.

ARG CUDA_IMAGE=nvidia/cuda:13.0.3-devel-ubuntu24.04
FROM ${CUDA_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    VIRTUAL_ENV=/opt/exl3 \
    PATH=/opt/exl3/bin:/usr/local/cuda/bin:$PATH \
    CUDA_HOME=/usr/local/cuda \
    TORCH_CUDA_ARCH_LIST=12.0;12.1 \
    MAX_JOBS=8

RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-venv python3-dev python3-pip \
      git build-essential ninja-build ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY tools/serve_openai.py /app/tools/serve_openai.py
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cu130
ARG EXL3_REPO=git+https://github.com/MiaAI-Lab/exllamav3
RUN python3 -m venv /opt/exl3 \
 && /opt/exl3/bin/pip install --upgrade pip setuptools wheel typing_extensions packaging \
 && /opt/exl3/bin/pip install torch --extra-index-url "${TORCH_INDEX_URL}" \
 && /opt/exl3/bin/pip install --no-build-isolation "${EXL3_REPO}" \
 && /opt/exl3/bin/pip install aiohttp huggingface_hub

EXPOSE 8976
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
