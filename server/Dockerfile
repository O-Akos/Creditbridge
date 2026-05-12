FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# A te szervered a képek alapján az index.js-t használja
EXPOSE 5000

CMD ["node", "index.js"]