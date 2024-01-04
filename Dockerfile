FROM nginx:1.25.3-bookworm

# Install required dependencies
USER root
RUN apt-get update \
    && apt install -y --no-install-recommends --no-install-suggests \
        git \
        wget \
        build-essential \
        libgd-dev \
        libpcre2-dev \
        libpcre3 \
        libpcre3-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and compile NGINX from source
WORKDIR /opt
RUN wget https://nginx.org/download/nginx-1.25.3.tar.gz \
    && tar axf nginx-1.25.3.tar.gz \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && mkdir -p /var/lib/nginx/body \ 
    && cd nginx-1.25.3 \
    && ./configure --with-cc-opt='-g -O2 -fdebug-prefix-map=/build/nginx-lUTckl/nginx-1.18.0=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' \
                   --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' \
                   --with-ld-opt=-Wl,-export-dynamic \
                   --prefix=/etc/nginx \
                   --sbin-path=/usr/sbin/nginx \
                   --conf-path=/etc/nginx/nginx.conf \
                   --http-log-path=/var/log/nginx/access.log \
                   --error-log-path=/var/log/nginx/error.log \
                   --lock-path=/var/lock/nginx.lock \
                   --pid-path=/run/nginx.pid \
                   --modules-path=/usr/lib/nginx/modules \
                   --http-client-body-temp-path=/var/lib/nginx/body \
                   --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
                   --http-proxy-temp-path=/var/lib/nginx/proxy \
                   --http-scgi-temp-path=/var/lib/nginx/scgi \
                   --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
                   --with-debug \
                   --with-compat \
                   --with-pcre-jit \
                   --with-http_ssl_module \
                   --with-http_stub_status_module \
                   --with-http_realip_module \
                   --with-http_auth_request_module \
                   --with-http_v2_module \
                   --with-http_dav_module \
                   --with-http_slice_module \
                   --with-threads \
                   --with-http_addition_module \
                   --with-http_gunzip_module \
                   --with-http_gzip_static_module \
                   --with-http_image_filter_module=dynamic \
                   --with-http_sub_module \
                   --with-http_xslt_module=dynamic \
                   --with-stream \
                   --with-stream_ssl_module \
                   --with-mail=dynamic \
                   --with-mail_ssl_module \
                   --add-module=../headers-more-nginx-module \
                   --add-module=../nginx-module-vts \
    && make -j 12 \
    && make install \
    && rm -rf /opt/*

WORKDIR /etc/nginx/
# RUN groupadd -r nginx && useradd -r -g nginx nginx
# USER nginx
COPY ./nginx-sample/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-sample/vts.conf /etc/nginx/conf.d/default.conf