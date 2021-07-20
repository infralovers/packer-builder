ARG PACKER_VERSION=1.7.3
FROM hashicorp/packer:$PACKER_VERSION

RUN apk add --no-cach --quiet jq aws-cli gettext bash curl \
    && curl -sSL https://mondoo.io/download.sh | bash \
    && mv mondoo /usr/local/bin/ \
    && mkdir -p ~/.packer.d/plugins \
    && curl https://releases.mondoo.io/packer-provisioner-mondoo/latest.json | jq -r '.files[] | select (.platform=="linux").filename' | xargs -n 1 curl | tar -xz > ~/.packer.d/plugins/packer-provisioner-mondoo \
    && chmod +x ~/.packer.d/plugins/packer-provisioner-mondoo


ENTRYPOINT ["/bin/bash"]
