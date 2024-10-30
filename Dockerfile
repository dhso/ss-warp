FROM ubuntu:22.04

ARG TZ='Asia/Shanghai'

ENV TZ ${TZ}

ENV WARP_LICENSE=
ENV TEAMS_ENROLL_TOKEN=
ENV FAMILIES_MODE=off

ENV SS_LIBEV_VERSION v3.3.5
ENV KCP_VERSION 20210103
ENV V2RAY_PLUGIN_VERSION v1.3.2
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev.git 
ENV KCP_DOWNLOAD_URL https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz
ENV PLUGIN_OBFS_DOWNLOAD_URL https://github.com/shadowsocks/simple-obfs.git
ENV PLUGIN_V2RAY_DOWNLOAD_URL https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_PLUGIN_VERSION}.tar.gz

# EXPOSE 1080/tcp

RUN apt update && \
  apt install curl gpg wget shadowsocks-libev -y \
  && curl -o v2ray_plugin.tar.gz -sSL ${PLUGIN_V2RAY_DOWNLOAD_URL} \
  && tar -zxf v2ray_plugin.tar.gz \
  && mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
  && rm -f v2ray_plugin.tar.gz \
  && curl -sSLO ${KCP_DOWNLOAD_URL} \
  && tar -zxf kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
  && mv server_linux_amd64 /usr/bin/kcpserver \
  && mv client_linux_amd64 /usr/bin/kcpclient \
  && rm -f kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
  && curl https://pkg.cloudflareclient.com/pubkey.gpg | \
  gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | \
  tee /etc/apt/sources.list.d/cloudflare-client.list && \
  apt update && \
  apt install cloudflare-warp -y && \
  rm -rf /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh entrypoint.sh
COPY --chmod=755 yxip.sh /usr/local/bin/yxip.sh
COPY --chmod=755 yxwarp /usr/local/bin/yxwarp
COPY --chmod=755 nf /usr/local/bin/nf

VOLUME ["/var/lib/cloudflare-warp"]
WORKDIR /var/lib/cloudflare-warp
CMD ["/bin/bash", "/entrypoint.sh"]