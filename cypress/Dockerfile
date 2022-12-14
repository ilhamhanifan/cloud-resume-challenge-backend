FROM cypress/include

WORKDIR /root

COPY package.json ./
RUN yarn install

CMD ["yarn", "run", "cy:run"]
