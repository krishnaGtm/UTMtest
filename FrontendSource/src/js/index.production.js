import 'babel-polyfill';
import 'es6-promise';
import React from 'react';
import 'react-tabs/style/react-tabs.scss';
import { render } from 'react-dom';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware, compose } from 'redux';
import createSagaMiddleware from 'redux-saga';
import reducer from './reducers';
import '../styles/normalize.css';
import '../styles/index.scss';
import rootSaga from './saga/saga';
import App from './containers/App';

const sagaMiddleware = createSagaMiddleware();

const middleWares = [sagaMiddleware];
const enhancer = compose(
  applyMiddleware(...middleWares)
  // other store enhancers if any
);
const store = createStore(reducer, enhancer);
sagaMiddleware.run(rootSaga);

render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
);
