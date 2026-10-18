FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  wget \
  ca-certificates \
  ruby \
  && rm -rf /var/lib/apt/lists/*

ARG HUGO_VERSION=0.161.1
RUN ARCH=$(dpkg --print-architecture) && \
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${ARCH}.deb && \
  dpkg -i hugo_extended_${HUGO_VERSION}_linux-${ARCH}.deb && \
  rm hugo_extended_${HUGO_VERSION}_linux-${ARCH}.deb

WORKDIR /app

COPY . .

RUN ruby scripts/generate_index.rb && hugo --cleanDestinationDir

EXPOSE 1313

CMD ["hugo", "server", "--logLevel", "debug", "--disableFastRender", "-p", "1313", "--bind", "0.0.0.0"]
