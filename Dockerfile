FROM node:22-alpine AS builder
WORKDIR /app

# Install git for submodule support
RUN apk add --no-cache git

# Copy package files first for better caching
COPY package*.json ./
RUN npm ci

# Copy all source files
COPY . .

# Initialize submodules (content from second-brain)
RUN git config --global --add safe.directory /app
RUN git config --global --add safe.directory /app/content
RUN git submodule update --init --recursive

# Build Quartz static site
RUN npx quartz build

# Production stage - serve with nginx
FROM nginx:alpine

# Copy built static files
COPY --from=builder /app/public /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
