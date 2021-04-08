FROM xsede/centos-nix-base:latest

SHELL ["/bin/bash", "-c"]

USER root

ENV NIXENV "/root/.nix-profile/etc/profile.d/nix.sh"

RUN mkdir -p /root/.config/nixpkgs/

COPY config.nix /root/.config/nixpkgs/
COPY dev.nix /root/
COPY prod-env.nix /root/
COPY persist-env.sh /root/

RUN for i in $(ls /root/.nix-profile/bin) ; do ln -s /root/.nix-profile/bin/"$i" /usr/bin ; done

RUN chmod +x /root/.nix-profile/etc/profile.d/nix.sh

# initiate environment
RUN $NIXENV && \
    cd /tmp && \
    bash /root/persist-env.sh /root/prod-env.nix

# Prep dev environment ahead of time
#RUN nix-shell /root/dev.nix

#It's worth noting that the following is a departure from the typical convention
# of the XSEDE CTL, but for the very simple case of containerizing a couple of python
# scripts with their dependencies, it remains illustrative.

RUN mkdir -m 755 -p /apps
COPY parallel_mandle.py /apps/
COPY zoom_mandle.py /apps/

ENTRYPOINT ["/apps/zoom_mandle.py"]
CMD ["-h"]
