ARG TERRAFORM_VERSION=1.0.11
ARG MONDOO_VERSION=5.35.0
ARG PACKER_VERSION=1.7.8
ARG YQ_VERSION=4.23.1

FROM docker.io/hashicorp/terraform:$TERRAFORM_VERSION as tf
FROM docker.io/mondoo/client:$MONDOO_VERSION as mondoo
FROM docker.io/mikefarah/yq:$YQ_VERSION as yq


FROM docker.io/hashicorp/packer:$PACKER_VERSION

RUN apk add --no-cache bash jq curl envsubst ruby-dev ruby-bundler make gcc g++ libc-dev ansible-base musl-dev python3-dev py3-pip libffi-dev openssl-dev cargo

RUN mkdir -p ~/.packer.d/plugins \
    && curl https://releases.mondoo.io/packer-provisioner-mondoo/latest.json | jq -r '.files[] | select (.platform=="linux").filename' | xargs -n 1 curl | tar -xz > ~/.packer.d/plugins/packer-provisioner-mondoo \
    && chmod +x ~/.packer.d/plugins/packer-provisioner-mondoo

COPY --from=yq /usr/bin/yq /usr/local/bin/yq
COPY --from=mondoo /usr/local/bin/mondoo /usr/local/bin/mondoo
COPY --from=tf /bin/terraform /usr/local/bin/terraform

RUN pip3 install azure-cli

ENTRYPOINT ["/bin/bash"]
