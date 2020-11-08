FROM php:7.4

COPY ./src /app

EXPOSE 80

WORKDIR /app/public

CMD [ "php", "-S", "0.0.0.0:80", "index.php" ]
