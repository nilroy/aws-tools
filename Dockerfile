FROM ruby:3.1.2-slim-bullseye

ENV DEBIAN_FRONTEND noninteractive
ENV PROJECT_NAME aws

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y groff curl git apt-transport-https ca-certificates jq gettext-base python3 python3-pip python-is-python3 \
    && groupadd -g 1024 ${PROJECT_NAME} \
    && useradd -u 1024 -g ${PROJECT_NAME} -s /bin/bash -d "/home/${PROJECT_NAME}" -m ${PROJECT_NAME}  \
    && mkdir -m 755 -p "/home/${PROJECT_NAME}" \
    && chown -R aws:aws "/home/${PROJECT_NAME}"



USER aws
WORKDIR /home/${PROJECT_NAME}

ENV PATH "/home/${PROJECT_NAME}/.local/bin:${PATH}"

COPY Gemfile .

RUN pip3 install --upgrade pip \
    && pip3 install awscli \
    && gem install bundler

CMD ["/bin/bash"]