FROM ruby:3.1.2

WORKDIR /app

ENV RAILS_ENV="production"

COPY . .
RUN bundle

ENTRYPOINT [ "rails s -b 0.0.0.0" ]
