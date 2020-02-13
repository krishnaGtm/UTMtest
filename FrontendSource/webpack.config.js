const webpack = require('webpack');
const { resolve } = require('path');
// const fs = require("fs");

const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: [
    'react-hot-loader/patch',
    'webpack-hot-middleware/client?https://localhost:9091', // Setting the URL for the hot reload
    'webpack/hot/only-dev-server', // Reload only the dev server
    resolve(__dirname, 'src', 'js', 'index.js')
    // resolve(__dirname, "src", "js", "tableSort.js")
  ],
  output: {
    filename: 'bundle.js',
    path: resolve(__dirname, 'dist'),
    publicPath: '/'
  },
  devtool: 'source-map',
  devServer: {
    historyApiFallback: true,
    contentBase: resolve(__dirname, 'src'),
    compress: true,
    hot: true,
    host: '0.0.0.0',
    port: 9091,
    inline: true,
    disableHostCheck: true, // That solved it
    stats: 'errors-only'
  },
  // https: true,
  resolve: {
    extensions: ['.js', '.jsx', '.json']
  },
  module: {
    rules: [
      {
        // js loading
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          babelrc: false,
          presets: [['es2015', { modules: false }], 'react', 'stage-2']
        }
      },
      // {
      //   // js loading
      //   test: /\.jsx?$/,
      //   exclude: /node_modules/,
      //   loader: 'eslint-loader'
      // },

      {
        // styles loading
        test: /\.css$/,
        loader: 'style-loader?sourceMap!css-loader?sourceMap'
      },
      {
        test: /\.scss$/,
        loader: 'style-loader!css-loader?sourceMap!sass-loader?sourceMap'
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff'
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader'
      },
      {
        test: /\.(gif|jpg|png)$/,
        loader: 'url-loader?limit=100000'
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin('style.css'),
    new webpack.HotModuleReplacementPlugin() // Wire in the hot loading plugin
  ]
};
