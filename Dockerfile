# Ruby 3.2 기반 이미지 사용
FROM ruby:3.2

# 필수 패키지 설치 (sqlite3, nodejs, yarn, 이미지 처리 등)
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs yarn imagemagick tzdata sqlite3 libsqlite3-dev

# 작업 디렉터리 생성
WORKDIR /app

# Gemfile, Gemfile.lock 복사 및 번들 설치
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# 소스 전체 복사
COPY . .

# Rails 자산 빌드
RUN bundle exec rails assets:precompile

# 포트 오픈
EXPOSE 3000

# entrypoint.sh 복사 및 실행 권한 부여
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]