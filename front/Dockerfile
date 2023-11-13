FROM node:18.7.0

COPY ./ /home/app

WORKDIR /home/app

RUN npm install

ENTRYPOINT ["npm", "start"]