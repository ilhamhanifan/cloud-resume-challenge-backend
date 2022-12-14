FROM cypress/included:12.1.0

WORKDIR /root

COPY package.json ./
RUN yarn install

CMD ["yarn", "run", "cy:run"]
