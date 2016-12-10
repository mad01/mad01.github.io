FROM jekyll/jekyll:2.4

RUN gem install rouge
WORKDIR /srv/jekyll
ADD . /srv/jekyll
