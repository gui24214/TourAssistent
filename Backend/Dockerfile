FROM node:20

WORKDIR /app

RUN npm install -g create-strapi-app

COPY restore.sh /restore.sh
RUN chmod +x /restore.sh

EXPOSE 1337

CMD ["/restore.sh"]