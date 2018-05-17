FROM alpine
LABEL maintainer="Christian Wagner https://github.com/chriswayg"
ENV container=docker
ENV TERM=xterm

# Install OpenRC, Python and Ansible.
RUN apk --no-cache add --update \
    openrc \
    busybox-initscripts \
    python3 \
    py-pip \
    ansible

# Install Ansible inventory file.
RUN mkdir -pv /etc/ansible \
 && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/tmp", "/run"]
CMD ["/sbin/init"]
