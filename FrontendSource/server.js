const http = require('http');
// const https = require('https');
const express = require('express');
const config = require('./config');

const app = express();

config.express(app, config.app);

const server = {
  start: function start() {
    const port = 9091;
    // const httpServer = http.createServer(app);
    const httpServer = http.createServer(app);
    httpServer.listen(port, '0.0.0.0');
    console.log(`Server running at http://localhost:${port}`);
  }
};
server.start();
