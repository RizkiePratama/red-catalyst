FROM fedora:34

# Use Bash
SHELL [ "/bin/bash", "-l", "-c" ]

# Install Dependencies
RUN dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
RUN dnf update -y
RUN dnf group install "C Development Tools and Libraries" -y
RUN dnf install unzip which procps findutils supervisor ffmpeg nginx ruby ruby-devel sqlite-devel -y

# Install SRS
WORKDIR /tmp
ADD https://github.com/ossrs/srs/releases/download/v5.0-a4/SRS-CentOS7-x86_64-5.0-a4.zip ./SRS.zip
RUN unzip SRS.zip
RUN mv SRS*/usr/local/srs /usr/local
RUN rm -rf *

# Copy Red Catalyst
COPY core /usr/local/red-catalyst
WORKDIR /usr/local/red-catalyst
RUN bundle

# Migrate and Initizlize Database
RUN rake db:migrate
RUN rake db:seed

# Create Red Catalyst Public Folder
RUN mkdir -p /var/red-catalyst/uploads

# COPY Config
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/srs/red-catalyst.conf /opt/srs/red-catalyst.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Run Container
CMD supervisord -c /etc/supervisor/supervisord.conf
