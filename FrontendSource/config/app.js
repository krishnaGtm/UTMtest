const path = require('path');

const rootPath = path.normalize(`${__dirname}/../`);
const publicPath = `${rootPath}src`;
const distPath = `${rootPath}dist`;
const libPath = `${rootPath}lib`;
const baseUrl = 'http://10.0.1.194:9091/';
const batch = 1;

console.log('=================================================');
console.log('Root Path : ', rootPath);
console.log('Public Path : ', publicPath);
console.log('Dist Path : ', distPath);
console.log('Lib Path : ', libPath);
console.log('BaseUrl : ', baseUrl);
console.log('Batch : ', batch);
console.log('=================================================');

module.exports = {
  rootPath,
  publicPath,
  distPath,
  libPath,
  baseUrl,
  batch
};
