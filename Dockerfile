# stage 1
FROM node:latest as node
WORKDIR docker/whalesay:latest
COPY . .
RUN npm install
RUN npm run build --prod

# stage 2
FROM httpd:2.4
COPY --from=node /app/dist/carc /etc/httpd

