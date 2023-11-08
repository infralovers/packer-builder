ARG TERRAFORM_VERSION=1.5.7
ARG MONDOO_VERSION=9.0.2
ARG PACKER_VERSION=1.9.4
ARG YQ_VERSION=4.35.2
ARG TERRAFORM_DOCS_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFSEC_VERSION=latest
ARG VAULT_VERSION=1.15.1

FROM docker.io/hashicorp/packer:$PACKER_VERSION as packer
FROM docker.io/mondoo/client:$MONDOO_VERSION as mondoo
FROM docker.io/mikefarah/yq:$YQ_VERSION as yq
FROM quay.io/terraform-docs/terraform-docs:$TERRAFORM_DOCS_VERSION as tfdocs
FROM ghcr.io/terraform-linters/tflint:$TFLINT_VERSION as tflint
FROM docker.io/aquasec/tfsec-alpine:$TFSEC_VERSION as tfsec
FROM docker.io/hashicorp/vault:${VAULT_VERSION} as vault

FROM docker.io/hashicorp/terraform:$TERRAFORM_VERSION as tf


# hadolint ignore=DL3018
RUN apk add --no-cache perl aws-cli bash git jq curl gettext ruby-dev ruby-bundler make gcc g++ libc-dev ansible musl-dev python3-dev py3-pip py3-ruamel.yaml py3-tomli libffi-dev openssl-dev cargo

COPY --from=yq /usr/bin/yq /usr/local/bin/yq
COPY --from=mondoo /usr/local/bin/mondoo /usr/local/bin/mondoo
COPY --from=packer /bin/packer /usr/local/bin/packer
COPY --from=tfdocs /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY --from=tflint /usr/local/bin/tflint /usr/local/bin/tflint
COPY --from=tfsec /usr/bin/tfsec /usr/local/bin/tfsec
COPY --from=vault /usr/local/bin/vault /usr/local/bin/vault

# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir azure-cli pre-commit

ENTRYPOINT ["/bin/bash"]
