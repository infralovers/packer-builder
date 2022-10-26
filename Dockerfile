ARG TERRAFORM_VERSION=1.3.3
ARG MONDOO_VERSION=7.1.0
ARG PACKER_VERSION=1.8.3
ARG YQ_VERSION=4.27.5
ARG TERRAFORM_DOCS_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFSEC_VERSION=latest

FROM docker.io/hashicorp/terraform:$TERRAFORM_VERSION as tf
FROM docker.io/mondoo/client:$MONDOO_VERSION as mondoo
FROM docker.io/mikefarah/yq:$YQ_VERSION as yq


FROM docker.io/hashicorp/packer:$PACKER_VERSION

# hadolint ignore=DL3018
RUN apk add --no-cache aws-cli bash git jq curl gettext ruby-dev ruby-bundler make gcc g++ libc-dev ansible musl-dev python3-dev py3-pip py3-ruamel.yaml py3-tomli libffi-dev openssl-dev cargo

# Terraform docs
# hadolint ignore=DL4006
RUN if [ "$TERRAFORM_DOCS_VERSION" != "false" ]; then \
    ( \
        TERRAFORM_DOCS_RELEASES="https://api.github.com/repos/terraform-docs/terraform-docs/releases" && \
        [ "$TERRAFORM_DOCS_VERSION" = "latest" ] && curl -L "$(curl -s ${TERRAFORM_DOCS_RELEASES}/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz \
        || curl -L "$(curl -s ${TERRAFORM_DOCS_RELEASES} | grep -o -E "https://.+?v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz")" > terraform-docs.tgz \
    ) && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs \
    ; fi

# TFLint
# hadolint ignore=DL4006
RUN if [ "$TFLINT_VERSION" != "false" ]; then \
    ( \
        TFLINT_RELEASES="https://api.github.com/repos/terraform-linters/tflint/releases" && \
        [ "$TFLINT_VERSION" = "latest" ] && curl -L "$(curl -s ${TFLINT_RELEASES}/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip \
        || curl -L "$(curl -s ${TFLINT_RELEASES} | grep -o -E "https://.+?/v${TFLINT_VERSION}/tflint_linux_amd64.zip")" > tflint.zip \
    ) && unzip tflint.zip && rm tflint.zip \
    ; fi

# TFSec
# hadolint ignore=DL4006
RUN if [ "$TFSEC_VERSION" != "false" ]; then \
    ( \
        TFSEC_RELEASES="https://api.github.com/repos/aquasecurity/tfsec/releases" && \
        [ "$TFSEC_VERSION" = "latest" ] && curl -L "$(curl -s ${TFSEC_RELEASES}/latest | grep -o -E -m 1 "https://.+?/tfsec-linux-amd64")" > tfsec \
        || curl -L "$(curl -s ${TFSEC_RELEASES} | grep -o -E -m 1 "https://.+?v${TFSEC_VERSION}/tfsec-linux-amd64")" > tfsec \
    ) && chmod +x tfsec \
    ; fi

COPY --from=yq /usr/bin/yq /usr/local/bin/yq
COPY --from=mondoo /usr/local/bin/mondoo /usr/local/bin/mondoo
COPY --from=tf /bin/terraform /usr/local/bin/terraform

# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir azure-cli pre-commit

ENTRYPOINT ["/bin/bash"]
