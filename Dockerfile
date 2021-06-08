# stage 1
FROM node:latest as node
WORKDIR /usr/src/app
COPY . .
RUN npm install
RUN npm run build --prod

# stage 2
FROM httpd:2.4

COPY httpd_start.sh /usr/src/app
# COPY --from=node /usr/src/app/dist/carc /var/www

# EXPOSE 80
CMD ["/usr/src/app/httpd_start.sh"]
