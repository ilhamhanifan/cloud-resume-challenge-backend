FROM cypress/included

WORKDIR /root

COPY package.json ./
RUN yarn install

CMD ["yarn", "run", "cy:run"]
