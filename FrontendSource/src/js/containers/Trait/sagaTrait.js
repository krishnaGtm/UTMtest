import { call, takeLatest, put } from 'redux-saga/effects';
import { token } from '../../saga/tokenSagas';
import { noInternet, notificationSuccess, notificationMsg } from '../../saga/notificationSagas';
import {
  storeCrops,
  storeTrait,
  storeDetermination,
  storeRelation,
  storeTotal,
  storePage,
  showNotification
} from './action';

import {
  getCropApi,
  getRelationApi,
  getRelationDeterminationApi,
  getRelationTraitApi,
  postRelationApi
} from './api';

function* getCrop() {
  try {
    yield call(token);
    const result = yield call(getCropApi);
    yield put(storeCrops(result.data));
  } catch (e) {
    console.log(e);
  }
}
export function* watchGetCrop() {
  yield takeLatest('FETCH_CROP', getCrop);
}

function* getTrait(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const { traitName, cropCode, sourceSelected } = action;
    yield call(token);
    const result = yield call(getRelationTraitApi, traitName, cropCode, sourceSelected);
    // console.log(result);
    yield put(storeTrait(result.data));
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    // console.log(e);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchGetTrait() {
  yield takeLatest('FETCH_TRAIT', getTrait);
}

function* getDetermination(action) {
  try {
    const { determinationName, cropCode } = action;
    yield call(token);
    const result = yield call(
      getRelationDeterminationApi,
      determinationName,
      cropCode
    );
    // console.log(result);
    yield put(storeDetermination(result.data));
  } catch (e) {
    // console.log(e);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchGetDetermination() {
  yield takeLatest('FETCH_DETERMINATION', getDetermination);
}

function* getRelation(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const { pageNumber, pageSize, filter } = action;
    // console.log(action);
    yield call(token);
    const result = yield call(getRelationApi, pageNumber, pageSize, filter);
    yield put(storeRelation(result.data.data));
    yield put(storePage(pageNumber));
    yield put(storeTotal(result.data.totalRows));
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    // console.log(e);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchGetRelation() {
  yield takeLatest('GET_RELATION', getRelation);
}

function* postRelation(action) {
  try {
    yield call(token);
    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(postRelationApi, action.data);
    yield put(storeRelation(result.data.data));
    yield put(storePage(action.data.pageNumber));
    yield put(storeTotal(result.data.totalRows));

    yield put({ type: 'LOADER_HIDE' });
    const mode = action.data.relationTraitDetermination[0].action || '';
    let msg = '';
    switch (mode) {
      case 'D':
        msg = 'Relation was blocked successfully';
        break;
      case 'U':
        msg = 'Relation was updated successfully';
        break;
      default:
        msg = 'Relation was created successfully.';
    }

    yield put(notificationSuccess(msg));
  } catch (e) {
    // console.log(e);
    if (e.response.data) {
      yield put({ type: 'LOADER_HIDE' });
      const error = e.response.data;
      const { message, errorType, code } = error;
      yield put(showNotification(message, errorType, code));
    }
  }
}
export function* watchPostRelation() {
  yield takeLatest('POST_RELATION', postRelation);
}
