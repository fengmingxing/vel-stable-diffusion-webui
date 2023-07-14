FROM cr-demo-cn-beijing.cr.volces.com/fengmingxing/cuda:11.4.3-devel-ubuntu20.04
LABEL org.opencontainers.image.authors="fengmingxing@bytedance.com"
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG DEBIAN_FRONTEND=noninteractive
#火山vpc环境下构建可以通过fasttrack加速
ENV http_proxy=http://100.68.174.39:3128
ENV https_proxy=http://100.68.174.39:3128
ENV TZ=Europe/Moscow
RUN apt-get update && apt-get install -y git ffmpeg libsm6 libxext6 wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    mkdir /root/.conda && \
    bash Miniconda3-latest-Linux-x86_64.sh -b && \
    rm -f Miniconda3-latest-Linux-x86_64.sh
#RUN conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=11.3 -c pytorch
RUN conda install pytorch==2.0.0 torchvision==0.15.0 torchaudio==2.0.0 pytorch-cuda=11.8 -c pytorch -c nvidia
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd stable-diffusion-webui && \
    mkdir repositories && \
    git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && \
    git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers && \
    git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && \
    git clone https://github.com/salesforce/BLIP.git repositories/BLIP && \
    git clone https://github.com/Stability-AI/stablediffusion repositories/stable-diffusion-stability-ai

RUN cd stable-diffusion-webui && \
    pip install transformers==4.19.2 diffusers==0.3.0 basicsr==1.4.2 gfpgan==1.3.8 gradio==3.30 numpy==1.23.3 Pillow==9.2.0 realesrgan==0.3.0 torch omegaconf==2.2.3 pytorch_lightning==1.7.6 scikit-image==0.19.2 fonts font-roboto timm==0.6.7 fairscale==0.4.9 piexif==1.1.3 einops==0.4.1 jsonmerge==1.8.0 clean-fid==0.1.29 resize-right==0.0.2 torchdiffeq==0.2.3 kornia==0.6.7 lark==1.1.2 inflection==0.5.1 GitPython==3.1.27 && \
    pip install git+https://github.com/crowsonkb/k-diffusion.git --prefer-binary && \
    pip install git+https://github.com/TencentARC/GFPGAN.git --prefer-binary && \
    pip install -r repositories/CodeFormer/requirements.txt --prefer-binary && \
    pip install -r requirements.txt  --prefer-binary && \
    pip install -U numpy  --prefer-binary && \
    pip install open_clip_torch && \
    pip install xformers==0.0.17
COPY ./misc.py /root/miniconda3/lib/python3.10/site-packages/basicsr/utils/misc.py
COPY ./ranged_response.py /root/miniconda3/lib/python3.10/site-packages/gradio/ranged_response.py
#如果使用了代理记得去掉环境变量，不然会有其他问题，例如只能使用--share，同时会有502 bad gateway报错
ENV http_proxy=
ENV https_proxy=
WORKDIR stable-diffusion-webui
CMD ["python", "webui.py", "--xformers", "--enable-insecure-extension-access", "--api", "--skip-install", "--listen","--ckpt-dir", "/stable-diffusion-webui/models/Stable-diffusion" ]
