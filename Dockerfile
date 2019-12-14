## Forked from https://github.com/MathWebSearch/latexml-mws-docker/blob/8e168f2f3f7240b82aef58c5a251bd143faae428/Dockerfile
## Dockerfile for latexml-plugin-ltxmojo with MathWebSearch support
## 
## To build this image, use:
##
## > docker build -t physikerwelt/latexml .
##
## You can optionally remove a full textlive installation to it, by
## setting the `WITH_TEXLIVE` build_arg to "no":
##
## > docker build -t physikerwelt/latexml --build-arg WITH_TEXLIVE=no .
##
## Building the image this way will take some time, and also make the image
## several gigabytes big. 
##
## The Docker Image exposes the web service on port 8080. To run it, use:
##
## docker run -p 8080:8080 --rm physikerwelt/latexml

FROM alpine:3.7

# Start by installing the system dependencies
RUN apk add --no-cache \
    db-dev \
    g++ \
    gcc \
    gcc \
    git \
    libc-dev \
    libgcrypt \
    libgcrypt-dev \
    libxml2 \
    libxml2-dev \
    libxslt \
    libxslt-dev \
    make \
    patch \
    perl \
    perl-dev \
    perl-utils \
    wget \
    zlib \
    zlib-dev

# Optionally enable support for TeXLive
# Use "yes" to enable, "no" to disable
ARG WITH_TEXLIVE="yes"

# Install TeXLive if not disabled
RUN [ "$WITH_TEXLIVE" == "no" ] || (\
           apk add --no-cache -U --repository http://dl-3.alpinelinux.org/alpine/edge/main      poppler harfbuzz-icu \
        && apk add --no-cache -U --repository http://dl-3.alpinelinux.org/alpine/edge/community zziplib texlive-full \
        && ln -s /usr/bin/mktexlsr /usr/bin/mktexlsr.pl \
    )

# install cpanminus
RUN apk add --no-cache -U --repository http://dl-3.alpinelinux.org/alpine/edge/community perl-app-cpanminus

# versions of LaTeXML and Mojolicious to install
# accepts anything cpanm-like, by default we simply
# the latest ones
ARG LATEXML_VERSION="LaTeXML"
ARG LATEXML_MWS_VERSION="https://github.com/MathWebSearch/LaTeXML-Plugin-MathWebSearch.git"
ARG MOJOLICIOUS_VERSION="Mojolicious"

# Add all of the files
RUN mkdir -p /opt/ltxmojo

# Install the plugin via cpanminus
WORKDIR /opt/ltxmojo
RUN git clone https://github.com/dginev/LaTeXML-Plugin-ltxmojo . && cpanm $LATEXML_VERSION $LATEXML_MWS_VERSION $MOJOLICIOUS_VERSION .

# just another build arg for install other plugins
ARG OTHER_PLUGINS=""
RUN [ "$OTHER_PLUGINS" == "" ] || cpanm $OTHER_PLUGINS .

# All glory to the hypnotoad on port 8080
EXPOSE 8080
ENTRYPOINT [ "hypnotoad", "-f", "script/ltxmojo" ]
