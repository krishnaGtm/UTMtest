import { call, takeLatest, put } from 'redux-saga/effects';
import { noInternet } from '../../saga/notificationSagas';

import { fetchGetExternalTestsApi, fetchGetExportApi } from './api';
import { token } from '../../saga/tokenSagas';

function* fetchGetExternalTests(action) {
  // console.log(action);
  try {
    yield call(token);
    yield put({ type: 'LOADER_SHOW' });

    const result = yield call(fetchGetExternalTestsApi, action);
    // console.log(result);
    yield put({
      type: 'EXPORT_ADD_BULK',
      data: result.data
    });

    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    // console.log(e);
    yield put({ type: 'LOADER_HIDE' });
    yield put(noInternet);
  }
}
export function* watchFetchGetExternalTests() {
  yield takeLatest('FETCH_EXTERNAL_TESTS', fetchGetExternalTests);
}

function* exportExternalTest(action) {
  try {
    yield call(token);
    yield put({ type: 'LOADER_SHOW' });

    const response = yield call(fetchGetExportApi, action);

    if (response.status === 200) {
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      const fn = action.fileName !== '' ? action.fileName : action.testID;
      link.setAttribute('download', `${fn}.xlsx`);
      document.body.appendChild(link);
      link.click();
    }

    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response.data) {
      const { data } = e.response;
      const decodedString = String.fromCharCode.apply(
        null,
        new Uint8Array(data)
      );
      const error = JSON.parse(decodedString);
      yield put({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: error.message,
        messageType: error.errorType,
        notificationType: 0,
        code: error.code
      });
    }
  }
}
export function* watchExportTest() {
  yield takeLatest('EXPORT_EXTERNAL_TEST', exportExternalTest);
}
