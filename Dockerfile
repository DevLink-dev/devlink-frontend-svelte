FROM node:22 AS build
WORKDIR /app

COPY package*.json .
RUN npm install

COPY . .
RUN npm run build

# Run build on given port
# https://kit.svelte.dev/docs/adapter-node#environment-variables-port-host-and-socket-path
ENV PORT 5173
EXPOSE 5173
CMD ["node", "build"]