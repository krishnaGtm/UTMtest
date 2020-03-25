import 'babel-polyfill';
import 'es6-promise';
import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import 'react-tabs/style/react-tabs.scss';
import { createStore, applyMiddleware, compose } from 'redux';
import createSagaMiddleware from 'redux-saga';
import { AppContainer } from 'react-hot-loader';
import reducer from './reducers';
import '../styles/normalize.css';
import '../styles/index.scss';
import rootSaga from './saga/saga';
import App from './containers/App';

const sagaMiddleware = createSagaMiddleware();

const loadState = () => {
  try {
    const serializedState = localStorage.getItem('state');
    if (serializedState === null) {
      return undefined;
    }
    return JSON.parse(serializedState);
  } catch (e) {
    return undefined;
  }
};
const saveState = state => {
  try {
    const serializedState = JSON.stringify(state);
    localStorage.setItem('state', serializedState);
  } catch (e) {
    console.log("Not able to save locally.");
  }
};

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__
    ? window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({})
    : compose;
const enhancer = composeEnhancers(applyMiddleware(sagaMiddleware));

const store = createStore(reducer, loadState(), enhancer);

store.subscribe(() =>
  saveState({
    sidemenuReducer: store.getState().sidemenuReducer
  })
);

sagaMiddleware.run(rootSaga);

// window.watcher = null;

const render = MyApp => {
  ReactDOM.render(
    <AppContainer>
      <Provider store={store}>
        <MyApp />
      </Provider>
    </AppContainer>,
    document.getElementById('root')
  );
};
render(App);

if (module.hot) {
  module.hot.accept('./containers/App', () => {
    render(App);
  });
}
