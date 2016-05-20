FROM node:5
EXPOSE 80
ADD . .
RUN cd programs/server && npm install
CMD node main.js
