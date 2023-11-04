FROM gitpod/openvscode-server:latest

USER root

# Install Python 3.10 from official Docker image
RUN apt-get update && \
    apt-get install -y python3.10 python3.10-dev && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --config python3

# Install pip for Python 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py

# Install Poetry using pip
RUN pip3 install poetry

# Install Git, Redis-client, Pgcli
RUN apt-get install -y git redis-tools pgcli nano vim

# Add your script here
COPY setup-zsh.sh /home/workspace/setup-zsh.sh

# Make the script executable
RUN chmod +x /home/workspace/setup-zsh.sh

# Run your script
# RUN bash /home/workspace/setup-zsh.sh

# Delete the script
RUN rm /home/workspace/setup-zsh.sh

# Add your zshrc here
COPY .zshrc /home/workspace/.zshrc

USER openvscode-server

WORKDIR /home/openvscode-server
