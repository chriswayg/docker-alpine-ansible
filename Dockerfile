FROM alpine
LABEL maintainer="Christian Wagner https://github.com/chriswayg"
ENV container=docker
ENV TERM=xterm

# Install OpenRC, Python and Ansible.
RUN apk --no-cache add --update \
      openrc \
      busybox-initscripts \
      python3 \
      ansible \
 # Disable getty's
 && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
 && sed -i \
      # Change subsystem type to "docker"
      -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
      # Allow all variables through
      -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
      # Start crashed services
      -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
      -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
      # Define extra dependencies for services
      -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
      /etc/rc.conf \
 && cat /etc/rc.conf \
 # Remove unnecessary services
 && rm -vf \
      /etc/init.d/hwdrivers \
      /etc/init.d/hwclock \
      /etc/init.d/modules \
      /etc/init.d/modules-load \
      /etc/init.d/modloop \
 # Can't do cgroups
 && sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
 && cat /lib/rc/sh/openrc-run.sh \
 && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
 && cat /lib/rc/sh/init.sh

# Install Ansible inventory file.
RUN mkdir -pv /etc/ansible \
 && echo -e '[local]\nlocalhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3' > /etc/ansible/hosts

VOLUME ["/tmp", "/run"]
CMD ["/sbin/init"]
