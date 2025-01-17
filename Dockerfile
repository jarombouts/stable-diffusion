FROM nvidia/cuda:11.3.1-base-ubuntu20.04

# Install some stuff that is nice to have
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive  apt install -y software-properties-common git wget

# Get miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh \
      -O Miniconda3-latest-Linux-x86_64.sh
RUN yes yes | bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda

# Add some more stuff that computer vision tools usually depend on
RUN apt update
RUN apt install -y ffmpeg libsm6 libxext6 libglib2.0-0 libsm6 libxrender-dev libxext6
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

# Ensure conda executables can be found; clean up conda install
ENV PATH="/root/miniconda/bin:${PATH}"
ARG PATH="/root/miniconda/bin:${PATH}"
RUN rm Miniconda3-latest-Linux-x86_64.sh

# Create conda environment
WORKDIR /app
COPY ./environment.yaml /app/environment.yaml
RUN /root/miniconda/bin/conda env create -f environment.yaml

# Copy codebase into app; install repo into conda env
COPY . /app
RUN /root/miniconda/envs/ldm/bin/python -m pip install -e .

# self-test
RUN /root/miniconda/envs/ldm/bin/python scripts/txt2img.py --help #--prompt "a photograph of an astronaut riding a horse" --plms

# get jupyter notebook
RUN /root/miniconda/envs/ldm/bin/python -m pip install jupyter
RUN mkdir /root/.jupyter
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

ENV PYTHONPATH='/app'
ENTRYPOINT /root/miniconda/envs/ldm/bin/jupyter notebook --allow-root
# some extra stuff I think I need
#RUN apt install -y vim
#RUN /root/miniconda/envs/ldm/bin/python -m pip install imgcat

# NOTE THE FOLLOWING:
# before building this dockerfile, get the model weights!
# store them in /models/ldm/stable-diffusion-v1/model.ckpt
# curl https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media \
#      > /models/ldm/stable-diffusion-v1/model.ckpt