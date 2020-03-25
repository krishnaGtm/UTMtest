import { call, takeLatest, put } from 'redux-saga/effects';
import { token } from '../../saga/tokenSagas';
import { notificationSuccess } from '../../saga/notificationSagas';
import {
  getTraitRelationApi,
  postTraitRelationApi,
  getTraitValuesApi,
  getCheckValidationApi
} from './api';
import {
  storeResult,
  storeTotal,
  showNotification,
  // storeAppend,
  storePage,
  storeTraitValues,
  storeCheckValidtion
} from './action';

function* getResult(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const { pageNumber, pageSize, filter } = action;
    const result = yield call(
      getTraitRelationApi,
      pageNumber,
      pageSize,
      filter
    );
    // console.log('get result', result.data);
    yield put(storeResult(result.data.data));
    yield put(storePage(pageNumber));
    yield put(storeTotal(result.data.totalRows));
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    console.log(e);
  }
}
export function* watchGetResult() {
  yield takeLatest('GET_RESULT', getResult);
}

function* getTraitValues(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const { cropCode, traitID, cropTraitID } = action;
    const result = yield call(
      getTraitValuesApi,
      cropTraitID,
      cropCode,
      traitID
    );

    if (result.status === 200) {
      yield put(storeTraitValues(result.data));
    }

    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    console.log(e);
  }
}
export function* watchGetTraitValues() {
  yield takeLatest('FETCH_TRAITVALUES', getTraitValues);
}

function* getCheckValidation(action) {
  try {
    const { source } = action;
    const result = yield call(getCheckValidationApi, source);
    const { data } = result;
    if (data.length === 0) {
      const msg = 'No result mapping missing.';
      yield put(notificationSuccess(msg));
    } else {
      yield put(storeCheckValidtion(data));
    }
  } catch (e) {
    console.log(e);
  }
}
export function* watchGetCheckValidation() {
  yield takeLatest('getCheckValidation', getCheckValidation);
}

function* postResult(action) {
  try {
    // console.log(action.data);
    yield call(token);
    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(postTraitRelationApi, action.data);
    yield put({ type: 'LOADER_HIDE' });
    if (result.data) {
      yield put(storeResult(result.data.data));
      yield put(storePage(action.data.pageNumber || 1));
      yield put(storeTotal(result.data.totalRows));

      const mode = action.data.data[0].action || '';
      // console.log(mode);
      let msg = '';
      switch (mode) {
        case 'D':
          msg = 'Result was removed successfully';
          break;
        case 'U':
          msg = 'Result was updated successfully';
          break;
        default:
          msg = 'Result was created successfully.';
      }
      yield put(notificationSuccess(msg));
    }
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response.data) {
      const error = e.response.data;
      const { code, errorType, message } = error;
      yield put(showNotification(message, errorType, code));
    }
  }
}
export function* watchPostResult() {
  yield takeLatest('POST_RESULT', postResult);
}
