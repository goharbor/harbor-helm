FROM alpine:3

ARG KUBECTL_VERSION="v1.14.1"
ARG HELM_VERSION="v3.5.4"
RUN apk add bash curl bind-tools \
    && curl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl \
    && curl https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
