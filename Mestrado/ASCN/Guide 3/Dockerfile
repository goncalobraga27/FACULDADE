FROM ubuntu:20.04

CMD apt update && \
    apt install -y software-properties-common && \
    apt update && \
    add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install -y php7.4 php7.4-fpm php7.4-zIP php7.4-mbstring php7.4-tokenizer php7.4-mysql php7.4-gd php7.4-xml php7.4-bcmath php7.4-intl php7.4-curl nodejs composer npm && \
    git clone https://github.com/Hackathonners/swap

WORKDIR swap

COPY .env.example .env

RUN composer install && \
    npm install && \
    sed -i 's/DB_HOST=.*/DB_HOST=swap/' .env && \
    sed -i 's/DB_DATABASE=.*/DB_DATABASE=swap/' .env && \
    sed -i 's/DB_USERNAME=.*/DB_USERNAME=swap/' .env && \
    sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=swap/' .env

RUN php artisan key:generate

