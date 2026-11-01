FROM nginx

WORKDIR /app

EXPOSE 80

COPY ./conf/nginx/app.conf.template /etc/nginx/templates/default.conf.template
COPY ./src/public /app/public
