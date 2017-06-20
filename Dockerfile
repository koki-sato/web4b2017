FROM ruby:2.2.3

ENV BUNDLER_VERSION 1.14.6
RUN gem install bundler --version ${BUNDLER_VERSION}

WORKDIR /app
COPY . /app

RUN bundle install --deployment

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "-p", "4567", "-o", "0.0.0.0"]
