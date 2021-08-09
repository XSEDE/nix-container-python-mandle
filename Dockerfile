FROM xsede/centos-nix-base:latest

################## METADATA ######################

LABEL base_image="nix-python-mandle:v0.0.1"
LABEL version="1.0.0"
LABEL software="Mandle"
LABEL software.version="1.0.0"
LABEL about.summary="A simple Mandlebrot zoom-in gif generator"
LABEL about.home="https://github.com/XSEDE/nix-container-python-mandle"
LABEL about.documentation="https://github.com/XSEDE/nix-container-python-mandle"
LABEL about.license_file="https://github.com/XSEDE/nix-container-python-mandle"
LABEL about.license="MIT"
LABEL about.tags="example-container" 
LABEL extra.binaries="/apps/zoom_mandle.py"
LABEL authors="XCRI <help@xsede.org>"

################## ENVIRONMENT ######################
SHELL ["/bin/bash", "-c"]

USER root

ENV NIXENV "/root/.nix-profile/etc/profile.d/nix.sh"

RUN mkdir -p /root/.config/nixpkgs/

################## INSTALLATION ######################
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
