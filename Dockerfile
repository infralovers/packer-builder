ARG PACKER_VERSION=1.7.8
FROM hashicorp/packer:$PACKER_VERSION

ARG TERRAFORM_VERSION=1.0.11

RUN apk add --no-cach --quiet jq aws-cli gettext bash curl \
    && curl -sSL https://mondoo.io/download.sh | bash \
    && mv mondoo /usr/local/bin/ \
    && mkdir -p ~/.packer.d/plugins \
    && curl https://releases.mondoo.io/packer-provisioner-mondoo/latest.json | jq -r '.files[] | select (.platform=="linux").filename' | xargs -n 1 curl | tar -xz > ~/.packer.d/plugins/packer-provisioner-mondoo \
    && chmod +x ~/.packer.d/plugins/packer-provisioner-mondoo

RUN apk add --no-cache ruby-dev ruby-bundler make gcc g++ libc-dev ansible-base musl-dev python3-dev py3-pip libffi-dev openssl-dev cargo

RUN curl -fOL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN pip3 install azure-cli

ENTRYPOINT ["/bin/bash"]
