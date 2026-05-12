# Könnyű Node.js környezet
FROM node:18-alpine

WORKDIR /app

# Csak a függőségeket másoljuk először (így gyorsabb a build)
COPY package*.json ./
RUN npm install

# Másoljuk a kódot
COPY . .

# React alapértelmezett port
EXPOSE 3000

CMD ["npm", "start"]