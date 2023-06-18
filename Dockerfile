FROM cr-demo-cn-beijing.cr.volces.com/fengmingxing/cuda:11.4.3-devel-ubuntu20.04
LABEL org.opencontainers.image.authors="fengmingxing@bytedance.com"
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG DEBIAN_FRONTEND=noninteractive
#火山vpc环境下构建可以通过fasttrack加速
#ENV http_proxy=http://100.68.174.39:3128
#ENV https_proxy=http://100.68.174.39:3128
ENV TZ=Europe/Moscow
RUN apt-get update && apt-get install -y git ffmpeg libsm6 libxext6 wget && \ 
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    mkdir /root/.conda && \
    bash Miniconda3-latest-Linux-x86_64.sh -b && \
    rm -f Miniconda3-latest-Linux-x86_64.sh 
#RUN conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=11.3 -c pytorch 
RUN conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd stable-diffusion-webui && \
    git checkout "5ab7f213bec2f816f9c5644becb32eb72c8ffb89" && \
    mkdir repositories && \
    git clone git://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && \
    git clone git://github.com/CompVis/taming-transformers.git repositories/taming-transformers && \
    git clone git://github.com/sczhou/CodeFormer.git repositories/CodeFormer && \
    git clone git://github.com/salesforce/BLIP.git repositories/BLIP && \
    git clone git://github.com/Stability-AI/stablediffusion repositories/stable-diffusion-stability-ai

RUN cd stable-diffusion-webui && \
    pip install transformers==4.19.2 diffusers invisible-watermark --prefer-binary && \
    pip install git+https://github.com/crowsonkb/k-diffusion.git --prefer-binary && \
    pip install git+https://github.com/TencentARC/GFPGAN.git --prefer-binary && \
    pip install -r repositories/CodeFormer/requirements.txt --prefer-binary && \
    pip install -r requirements.txt  --prefer-binary && \
    pip install -U numpy  --prefer-binary && \
    pip install open_clip_torch && \
    pip install xformers
#如果使用了代理记得去掉环境变量，不然会有其他问题，例如只能使用--share，同时会有502 bad gateway报错
#ENV http_proxy=
#ENV https_proxy=
WORKDIR stable-diffusion-webui
CMD ["python", "webui.py", "--xformers", "--enable-insecure-extension-access", "--api", "--skip-install", "--ckpt-dir", "/stable-diffusion-webui/models/Stable-diffusion" ]
