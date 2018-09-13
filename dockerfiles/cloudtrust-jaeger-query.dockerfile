FROM cloudtrust-baseimage:f27

ARG jaeger_query_git_tag
ARG jaeger_release=1.2.0
ARG config_git_tag
ARG config_repo

ARG nginx_version=1.12.1-1.fc27

###
###  Prepare the system stuff
###

RUN dnf -y install nginx-$nginx_version && \
    dnf clean all

RUN groupadd query && \
    useradd -m -s /sbin/nologin -g query query && \
    install -d -v -m755 /opt/query -o root -g root && \
    install -d -v -m755 /etc/query -o query -g query

WORKDIR /cloudtrust
RUN git clone git@github.com:cloudtrust/jaeger-query.git && \
    git clone ${config_repo} ./config

WORKDIR /cloudtrust/jaeger-query
RUN git checkout ${jaeger_query_git_tag}

WORKDIR /cloudtrust/jaeger-query
RUN install -v -m0644 deploy/etc/security/limits.d/* /etc/security/limits.d/ && \
    install -v -m0644 deploy/etc/monit.d/* /etc/monit.d/ && \
    install -v -m0644 -D deploy/etc/nginx/conf.d/* /etc/nginx/conf.d/ && \
    install -v -m0644 deploy/etc/nginx/nginx.conf /etc/nginx/nginx.conf && \
    install -v -m0644 deploy/etc/nginx/mime.types /etc/nginx/mime.types && \
    install -v -o root -g root -m 644 -d /etc/systemd/system/nginx.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/nginx.service.d/limit.conf /etc/systemd/system/nginx.service.d/limit.conf

##
##  Jaeger query
##

WORKDIR /cloudtrust
RUN wget ${jaeger_release} -O jaeger.tar.gz && \
    mkdir jaeger && \
    tar -xzf jaeger.tar.gz -C jaeger --strip-components 1 && \
    install -v -m 755 jaeger/query-linux /opt/query/query && \
    mv jaeger/jaeger-ui-build /etc/query/ && \
    chmod 775 -R /etc/query/ && \
    rm jaeger.tar.gz && \
    rm -rf jaeger/

WORKDIR /cloudtrust/jaeger-query
RUN install -v -o query -g query -m 644 deploy/etc/systemd/system/query.service /etc/systemd/system/query.service && \
    install -d -v -o root -g root -m 644 /etc/systemd/system/query.service.d && \
    install -v -o root -g root -m 644 deploy/etc/systemd/system/query.service.d/limit.conf /etc/systemd/system/query.service.d/limit.conf

##
##  Config
##

WORKDIR /cloudtrust/config
RUN git checkout ${config_git_tag}

WORKDIR /cloudtrust/config
RUN install -v -m0755 -o query -g query deploy/etc/jaeger-query/ui-config.json /etc/query/  && \
    install -v -m0755 -o query -g query deploy/etc/jaeger-query/query.yml /etc/query/

##
##  Enable services
##

RUN systemctl enable query.service && \
    systemctl enable nginx.service && \
    systemctl enable monit.service
