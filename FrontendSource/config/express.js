const express = require('express');

const allowCrossDomain = (req, res, next) => {
  res.header('Cache-Control', 'no-cache');
  res.header('Access-Control-Allow-Origin', 'http://10.0.1.44:8081');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
  // res.header('Access-Control-Allow-Headers', 'Authorization, referrer, user, Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Allow-Headers', '*');
  if (req.method === 'OPTIONS') {
    // res.header('Access-Control-Allow-Headers', 'Authorization, referrer, user, Origin, X-Requested-With, Content-Type, Accept');
    res.status(200).end();
  } else {
    next();
  }
};

function expressConfig(app, config) {
  app.set('view engine', 'html');
  const env = app.get('env');
  app.use(allowCrossDomain);
  if (env === 'production') {
    app.use(express.static(`${config.distPath}`));
    app.get('/*', (req, res) => {
      res.sendFile(`${config.publicPath}/index.html`);
    });
  }
  else if (env === 'development' || env === 'test') {
    app.use(express.static(`${config.publicPath}`));

    const webpack = require('webpack');
    const webpack_cfg = require(`${config.publicPath}/../webpack.config.js`);
    const webpackMiddleware = require('webpack-dev-middleware');
    const webpackHotMiddleware = require('webpack-hot-middleware');
    const compiler = webpack(webpack_cfg);

    // attach dev middleware to hte compiler and the server
    const middleware = webpackMiddleware(compiler, {
      publicPath: webpack_cfg.output.publicPath,
      stats: {
        colors: true,
        hash: false,
        timings: true,
        chunks: false,
        chunkModules: false,
        modules: false
      }
    });

    app.use(middleware);
    // Attach the hot middleware to the compiler & the server
    app.use(
      webpackHotMiddleware(compiler, {
        log: console.log,
        path: '/__webpack_hmr',
        heartbeat: 2000
      })
    );

    app.get('/*', (req, res) => {
      res.sendFile(`${config.publicPath}/index.html`);
    });
  }
}
module.exports = expressConfig;
