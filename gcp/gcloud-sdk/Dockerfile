ARG GCLOUD_SDK_VERSION

FROM gcr.io/google.com/cloudsdktool/cloud-sdk:$GCLOUD_SDK_VERSION

WORKDIR /work

RUN apt-get install -t \
        kubectl
