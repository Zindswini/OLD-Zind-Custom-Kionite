ARG BASE_REPO=quay.io/fedora-ostree-desktops/kinoite
ARG BASE_TAG=37
FROM ${BASE_REPO}:${BASE_TAG}

ENTRYPOINT ["/bin/bash"]

# Each block represents a set of related changes, which should turn into layers when built.
# Keeping these small keeps update deltas small. (I think)

# Setup Repos
RUN rm -rf /etc/yum.repos.d


# VERY IMPORTANT: This is where a lot of customizations happen
# Most Notably: Copy of Nobara-Fedora repos, custom services, list of flatpaks
COPY root/ /

# Install RPM Fusion

# Remove packaged Firefox, enable automatic updates
RUN rpm-ostree override remove firefox firefox-langpacks && \
    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-automatic.timer && \
    ostree container commit


# These packages are meant to enhanve the desktop experience, not the terminal experience.
# Any terminal enhancements can be manually installed inside a distrobox container.

RUN set -x; arch=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'); cat /etc/os-release \
    && rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    && ostree container commit

RUN set -x; PACKAGES_INSTALL="bridge-utils conntrack-tools curl fping iftop iputils iproute mtr nethogs socat"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="net-tools bind-utils iperf iperf3 iputils mtr ethtool tftp wget ipmitool"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="gawk htop ncdu procps strace iotop"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="subversion git git-lfs"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="gnupg2 openssl openvpn rsync tcpdump nmap nmap-ncat krb5-workstation"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="qemu-kvm qemu-user-static"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="libvirt"; \
    rpm-ostree install $PACKAGES_INSTALL && rm -rf /var/* && ostree container commit

RUN set -x; PACKAGES_INSTALL="sudo screen unzip util-linux-user ignition"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

#RUN set -x; PACKAGES_INSTALL="zsh"; \
#    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="python3-pip"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="skopeo jq"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="vim neovim"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="mozilla-openh264"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="make gcc"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; if rpm -qa | grep -q gnome-desktop; then \
    PACKAGES_INSTALL="gnome-tweaks tilix gnome-extensions-app gedit evince"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit; fi

# Installing docker-ce nightly: if building on top of Fedora rawhide, there are no repositories for its $releasever value.
# The below code executes a request to the docker-ce repository root for version $VERSION_ID, initially equal to the
# Fedora version being built. VERSION_ID decrements, at most 3 times, until the response code of the request is 200.
# Then, the resulting VERSION_ID statically replaces the $releasever variable in the final repo file.

# Disabled in favor of podman
#RUN set -x; \
#    source /etc/os-release; \
#    curl -L https://download.docker.com/linux/fedora/docker-ce.repo | releasever=37 envsubst '$releasever' \
#        | tee /etc/yum.repos.d/docker-ce.repo \
# && rpm-ostree install docker-ce docker-ce-cli && ostree container commit

# RUN HOME=/tmp RUNZSH=no CHSH=no ZSH=/usr/lib/ohmyzsh \
#     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
#     && set -x \
#     && wget -qO /usr/lib/ohmyzsh/custom/kube-ps1.plugin.zsh \
#         https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/kube-ps1/kube-ps1.plugin.zsh \
#     && mv /usr/share/zsh/*.zsh /usr/lib/ohmyzsh/custom/ \
#     && git clone https://github.com/zsh-users/zsh-history-substring-search \
#      /usr/lib/ohmyzsh/custom/plugins/zsh-history-subscring-search \
#     && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
#      /usr/lib/ohmyzsh/custom/plugins/zsh-syntax-highlighting \
#     && chsh -s /bin/zsh root \
#     && echo 'PATH=~/bin:~/.bin:~/.opt/bin:$PATH' >> /etc/zshenv \
#     && sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd \
#     # ${VARIANT_ID^} is not posix compliant and is not parsed correctly by zsh \
#     && sed -i 's/VARIANT_ID^/VARIANT_ID/' /etc/profile.d/toolbox.sh \
#     && ostree container commit
