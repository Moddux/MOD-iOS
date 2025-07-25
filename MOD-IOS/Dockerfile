FROM nvidia/cuda:12.2.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Copy and run dependency installer
COPY install_deps.sh .
RUN chmod +x install_deps.sh && ./install_deps.sh

# Copy remaining app files if needed (placeholder)
COPY . .

CMD ["/bin/bash"]
