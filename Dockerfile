FROM hub.atomgit.com/library/alpine:3.18

# Copy necessary files
COPY scripts /scripts
COPY pipeline /pipeline
COPY src/main/resources/static/fonts/*.ttf /usr/share/fonts/opentype/noto/
COPY build/libs/*.jar app.jar

ARG VERSION_TAG

# Set Environment Variables
ENV DOCKER_ENABLE_SECURITY=false \
    VERSION_TAG=$VERSION_TAG \
    JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -XX:MaxRAMPercentage=75" \
    HOME=/home/stirlingpdfuser \
    PUID=1000 \
    PGID=1000 \
    UMASK=022

# Use Aliyun mirror for apk
RUN echo "https://mirrors.aliyun.com/alpine/v3.17/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.17/community" >> /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/edge/main" >> /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/edge/community" >> /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade --no-cache -a || true

# Install necessary packages
RUN apk add --no-cache \
        ca-certificates \
        tzdata \
        tini \
        bash \
        curl \
        shadow \
        su-exec \
        openssl \
        openssl-dev \
        openjdk21-jre \
        libreoffice \
        poppler-utils \
        ocrmypdf \
        tesseract-ocr-data-eng \
        py3-opencv \
        python3 \
        py3-pip && \
    pip install --break-system-packages --no-cache-dir --upgrade unoconv WeasyPrint pdf2image pillow && \
    mv /usr/share/tessdata /usr/share/tessdata-original && \
    mkdir -p $HOME /configs /logs /customFiles /pipeline/watchedFolders /pipeline/finishedFolders && \
    fc-cache -f -v && \
    chmod +x /scripts/* && \
    chmod +x /scripts/init.sh && \
    addgroup -S stirlingpdfgroup && adduser -S stirlingpdfuser -G stirlingpdfgroup && \
    chown -R stirlingpdfuser:stirlingpdfgroup $HOME /scripts /usr/share/fonts/opentype/noto /configs /customFiles /pipeline && \
    chown stirlingpdfuser:stirlingpdfgroup /app.jar && \
    tesseract --list-langs

EXPOSE 8080/tcp

# Set user and run command
ENTRYPOINT ["tini", "--", "/scripts/init.sh"]
CMD ["java", "-Dfile.encoding=UTF-8", "-jar", "/app.jar"]

