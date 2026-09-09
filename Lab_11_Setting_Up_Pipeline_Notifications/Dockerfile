FROM registry.access.redhat.com/ubi8/nodejs-16:latest

USER 0

COPY . /opt/app-root/src/

RUN chown -R 1001:0 /opt/app-root/src/

USER 1001

WORKDIR /opt/app-root/src

RUN npm install

EXPOSE 8080

CMD ["npm", "start"]
