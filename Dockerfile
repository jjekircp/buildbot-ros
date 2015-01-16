FROM ubuntu:trusty
MAINTAINER Jonathan Jekir

ENV DEBIAN_FRONTEND noninteractive
ENV BUILDBOT_CREATED jan_15_2015

# Install build, webserver, apt management stuff.
RUN sh -c 'echo deb http://repo.aptly.info/ squeeze main >/etc/apt/sources.list.d/aptly.list'

RUN gpg --keyserver keys.gnupg.net --recv-keys 2A194991
RUN gpg -a --export 2A194991 | apt-key add -

RUN apt-get update
RUN apt-get install -q -y --no-install-recommends \
  python-pip python-dev python-empy build-essential git ssh \
  cowbuilder debootstrap devscripts git-buildpackage \
  fakeroot debhelper debmirror nginx openssl aptly ccache

# Install buildbot itself.
RUN pip install rosdistro buildbot buildbot-slave

# Insert buildbot master configuration from this repo, and set up the PATH.
ADD . /buildbot-ros
ADD ./conf/pbuilderrc /root/.pbuilderrc
ENV PATH /buildbot-ros/scripts:$PATH

# Nginx is the package server and a reverse-proxy to Buildbot web UI.
EXPOSE 80

# Some miscellaneous configuration; things you might want to override.
ENV REPO_DIR /building
ENV REPO_NAME ExampleCo
ENV NUM_BUILDSLAVES 2

# You probably want to connect this externally to persist the built packages.
VOLUME /building

CMD run_container
