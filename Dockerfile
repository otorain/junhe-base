FROM ruby:2.6.5-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk update && apk add --no-cache

COPY node-v12.18.0-linux-x64-musl.tar.xz /usr/local/src/node-v12.18.0-linux-x64-musl.tar.xz

# install nodejs
RUN srcPath=/usr/local/src && \
      tar -Jxvf $srcPath/node-v12.18.0-linux-x64-musl.tar.xz -C $srcPath && \
      ln -s $srcPath/node-v12.18.0-linux-x64-musl/bin/node /usr/sbin/node && \
      ln -s $srcPath/node-v12.18.0-linux-x64-musl/bin/npm /usr/sbin/npm && \
      ln -s $srcPath/node-v12.18.0-linux-x64-musl/bin/npx /usr/sbin/npx

RUN mkdir /app

WORKDIR /app

ENV BUNDLE_PATH /bundle_cache

# build tool and git will be use in `bundle install` and `npm install`,
# so it should not be removed.
RUN buildDeps='libtool linux-headers' && \
  runDeps='git autoconf automake build-base postgresql-client \
    postgresql-dev zlib-dev pcre-dev openrc openssl-dev curl-dev nginx' && \
  apk --no-cache add $buildDeps $runDeps && \
  gem install bundler rails pg && \
  gem install nokogiri -v '1.10.5' && \
  gem install escape_utils -v '1.2.1' && \
  apk del $buildDeps

COPY site.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
