FROM node:lts-alpine

LABEL maintainer="Luiz Benevenuto <luiz@siffra.com.br>"

RUN apk add --no-cache nodejs && yarn global add @adonisjs/cli nodemon

ARG APP_CODE_PATH_CONTAINER=/var/www
WORKDIR ${APP_CODE_PATH_CONTAINER}

RUN yarn install

EXPOSE 3333

#CMD ["adonis", "serve", "--dev"]
CMD ["yarn", "serve:dev"]
