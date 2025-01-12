FROM node:22 AS build
WORKDIR /app

COPY package*.json .
RUN npm install

COPY . .
RUN npm run build

# Stage 1: Create production image
FROM node:22-alpine AS production
WORKDIR /app

# Install only production dependencies
COPY package*.json .
ENV NODE_ENV production
RUN npm ci --omit dev

# Copy build files from stage 0
COPY --from=build /app/build ./build

# Run build on given port
# https://kit.svelte.dev/docs/adapter-node#environment-variables-port-host-and-socket-path
ENV PORT 5173
EXPOSE 5173
CMD ["node", "build"]