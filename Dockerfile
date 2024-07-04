# Parent image built on top of a Linux distribution
FROM pytorch/pytorch:2.3.1-cuda11.8-cudnn8-devel

# Set the working directory
WORKDIR /app

# Copy the files into the container
COPY . /app/

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}"
ENV CUDA_HOME=/usr/local/cuda
ENV PATH /usr/local/cuda/bin:$PATH

# Install system dependencies for libGL & git
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    git \
    g++ \
    ninja-build

# Update Conda
RUN conda update -n base -c defaults conda -y
    ###conda install mamba -n base -c conda-forge -y

# Install TensorFlow and packages from requirements_conda.txt using Conda
RUN conda install -c conda-forge tensorflow=2.14 --file requirements_conda.txt -y
###RUN conda install -c conda-forge --file requirements_conda.txt -y

# Install packages from requirements_pip.txt using pip
RUN pip install --no-cache-dir -r requirements_pip.txt 
    ###pip install --no-cache-dir tensorflow==2.12

# Install required Python packages
# RUN pip install transformers==4.37.0
# RUN git clone https://github.com/AutoGPTQ/AutoGPTQ.git && \
#     cd AutoGPTQ && \
#     sed -i 's/from habana_frameworks.torch.core import htcore/try:\n    from habana_frameworks.torch.core import htcore\nexcept ImportError:\n    htcore = None/' auto_gptq/nn_modules/qlinear/qlinear_hpu.py && \
#     pip install -e .

# # Upgrade relevant packages
# RUN pip install --upgrade trl peft accelerate bitsandbytes datasets optimum -q

# Expose the port the app runs on
EXPOSE 8888

# Set up the entrypoint to start Jupyterlab
CMD ["jupyter", "lab", "--ip='0.0.0.0'", "--port=8888", "--no-browser", "--allow-root"]