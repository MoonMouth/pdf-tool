#!/bin/bash

docker run -itd \
  -p 9044:8080 \
  -e DOCKER_ENABLE_SECURITY=false \
  -e INSTALL_BOOK_AND_ADVANCED_HTML_OPS=false \
  -e LANGS=en_GB \
  --name pdf-tool \
  pdf-tool:v0.1
