ARG TERRAFORM_VERSION=1.3.3
ARG MONDOO_VERSION=7.1.0
ARG PACKER_VERSION=1.8.3
ARG YQ_VERSION=4.27.5

FROM docker.io/hashicorp/terraform:$TERRAFORM_VERSION as tf
FROM docker.io/mondoo/client:$MONDOO_VERSION as mondoo
FROM docker.io/mikefarah/yq:$YQ_VERSION as yq


FROM docker.io/hashicorp/packer:$PACKER_VERSION

# hadolint ignore=DL3018
RUN apk add --no-cache aws-cli bash git jq curl gettext ruby-dev ruby-bundler make gcc g++ libc-dev ansible musl-dev python3-dev py3-pip py3-ruamel.yaml py3-tomli libffi-dev openssl-dev cargo

COPY --from=yq /usr/bin/yq /usr/local/bin/yq
COPY --from=mondoo /usr/local/bin/mondoo /usr/local/bin/mondoo
COPY --from=tf /bin/terraform /usr/local/bin/terraform

# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir azure-cli pre-commit

ENTRYPOINT ["/bin/bash"]
