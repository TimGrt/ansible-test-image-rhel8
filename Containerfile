FROM registry.access.redhat.com/ubi8-init

LABEL org.opencontainers.image.title="Ansible Test Image RHEL8" \
      org.opencontainers.image.description="Systemd-enabled test image for Ansible based on UBI 8 with password-less sudo configured" \
      org.opencontainers.image.source="https://github.com/TimGrt/ansible-test-image-rhel8"

ARG PYTHON_VERSION=""

RUN yum -y install rpm dnf-plugins-core \
    && yum -y update \
    && yum -y install \
        initscripts \
        sudo \
        which \
        hostname \
    && [ -z "$PYTHON_VERSION" ] || yum install -y "python${PYTHON_VERSION}" \
    && yum clean all

RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

ENV ANSIBLE_USER=ansible

RUN set -xe \
    && useradd -m ${ANSIBLE_USER} \
    && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ansible

VOLUME [ "/sys/fs/cgroup" ]
CMD [ "/usr/sbin/init" ]