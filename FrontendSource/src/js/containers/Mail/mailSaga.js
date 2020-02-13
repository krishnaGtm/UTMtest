import { takeEvery } from 'redux-saga';
import { takeLatest, call, put, select } from 'redux-saga/effects';
// import axios from 'axios';
// import urlConfig from '../../../urlConfig';
import { token } from '../../saga/tokenSagas';
import { noInternet, notificationMsg } from '../../saga/notificationSagas';

import {
  MAIL_CONFIG_FETCH,
  MAIL_CONFIG_APPEND,
  MAIL_CONFIG_UPDATE,
  MAIL_CONFIG_DESTORY
} from './mailConstant';
import {
  mailConfig_fetchApi,
  mailConfig_appendApi,
  mailConfig_editApi,
  mailConfig_deleteApi
} from './mailApi';
import {
  mailConfig_fetch,
  mailConfig_append,
  mailConfig_edit,
  mailConfig_delete
} from './mailAction';

/**
 * Fetch Availabel Mail Config
 * Action / Act
 */
function* mailConfigFetch(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const tokenKey = yield call(token);
    const { pageNumber, pageSize } = action;

    const result = yield call(mailConfig_fetchApi, pageNumber, pageSize, tokenKey)
    // console.log(result);
    const { data, status } = result;
    if (status === 200) {
      yield put({
        type: 'MAIL_BULK',
        data: data.data
      });
      yield put({
        type: 'MAIL_RECORDS',
        total: data.total
      });
      yield put({
        type: 'MAIL_PAGE',
        pageNumber
      });
    }
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    // yield put(noInternet);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchMailConfigFetch() {
  yield takeLatest(MAIL_CONFIG_FETCH, mailConfigFetch )
}

/**
 * Append New Mail
 */
function* mailConfigAdd(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const tokenKey = yield call(token);
    const { configID, cropCode, configGroup, recipients } = action;

    const result = yield call(mailConfig_appendApi, configID, cropCode, configGroup, recipients, tokenKey);
    if (result.data) {
      const pageNumber = yield select(state => state.mailResult.total.pageNumber);
      const pageSize = yield select(state => state.mailResult.total.pageSize);

      yield put({
        type: MAIL_CONFIG_FETCH,
        pageNumber,
        pageSize
      })
    }
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    // console.log(e);
    yield put({ type: 'LOADER_HIDE' });
    // yield put(noInternet);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchMailConfigAdd() {
  yield takeLatest(MAIL_CONFIG_APPEND, mailConfigAdd);
}

/**
 * Update Existing Mail
 */

/**
 * Destroy Mail
 */
function* mailConfigDelete(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const tokenKey = yield call(token);

    const result = yield call(mailConfig_deleteApi, action.configID, tokenKey);

    if (result.data) {
      const pageSize = yield select(state => state.mailResult.total.pageSize);

      yield put({
        type: 'MAIL_PAGE',
        pageNumber: 1
      });
      yield put({
        type: MAIL_CONFIG_FETCH,
        pageNumber: 1,
        pageSize
      })
    }

    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    console.log(e);
    yield put({ type: 'LOADER_HIDE' });
    // yield put(noInternet);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchMailConfigDelete() {
  yield takeLatest(MAIL_CONFIG_DESTORY, mailConfigDelete);
}
