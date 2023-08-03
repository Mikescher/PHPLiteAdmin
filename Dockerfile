FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm php apache php-apache php-sqlite sqlite git vim && \
    rm -rf /var/cache/pacman/pkg/*

RUN mkdir -p /srv/http
COPY . /srv/http

COPY .docker /_docker

EXPOSE 80

CMD ["/_docker/run.sh"]
