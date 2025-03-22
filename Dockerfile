### Multistage Docker file
# Build stage
# Create Work Directory, everything in the current directory will be copied to WORKDIR /app which is current dir of Docker image.
# Copy the dependencies file to the working directory and install dependencies
# Docker has layer caching, so if the package.json file has not changed, the npm install command will not be run again.
# That means the dependencies will be cached and the build will be faster. Thats the reason why we copy the package.json file first and run npm install.
# Next Copy the rest of the application code to the working directory and build the application

FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN apk update && apk upgrade --no-cache
RUN npm ci
COPY . .
RUN npm run build

# Production stage
# Copy the build files from the build stage to nginx location and serve them with nginx
# The nginx image is used as a base image
# The build files are copied to /usr/share/nginx/html which is the default location for nginx to serve files from
# The port 80 is exposed and the nginx server is started
# CMD to start the nginx server

FROM nginx:alpine
RUN apk update && apk upgrade --no-cache
COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]