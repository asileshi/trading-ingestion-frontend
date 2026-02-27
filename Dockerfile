# ---- Build stage ----
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies first (better layer caching)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# ---- Runtime stage (serve static files) ----
FROM nginx:1.27-alpine AS runtime

# Copy the built Vite assets to nginx's default web root
COPY --from=build /app/dist /usr/share/nginx/html

# Nginx listens on 80 inside the container by default
EXPOSE 80

# Keep nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]