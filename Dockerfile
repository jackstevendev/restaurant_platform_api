FROM ruby:3.4

RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    build-essential

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

CMD [ "rails", "server", "-b", "0.0.0.0" ]
