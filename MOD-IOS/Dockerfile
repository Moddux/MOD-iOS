FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

COPY install_deps.sh .
RUN chmod +x install_deps.sh && ./install_deps.sh

COPY . .

RUN find cli/ modules/ tests/ -name "*.sh" -exec chmod +x {} \;
RUN chmod +x engine/meta_parser.py

ENTRYPOINT ["./cli/meta-ios.sh"]
