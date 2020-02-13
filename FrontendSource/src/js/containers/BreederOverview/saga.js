import { takeEvery } from 'redux-saga';
import { call, put } from 'redux-saga/effects';
// takeLatest
// import axios from 'axios';

import { token } from '../../saga/tokenSagas';
import { noInternet, notificationMsg } from '../../saga/notificationSagas';
// notificationSuccess
import { fetchSlotAPi } from './api';

/*
function fetchSlotAPi() {
  return axios({
    method: 'get',
    url: urlConfig.getSlotBreedingOverview,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    }
  });
}
*/

function* fetchSlot(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    const { cropCode, brStationCode, pageNumber, pageSize, filter } = action;
    const result = yield call(
      fetchSlotAPi,
      cropCode,
      brStationCode,
      pageNumber,
      pageSize,
      filter
    );
    yield put({
      type: 'BREEDER_SLOT',
      data: result.data.data
    });

    yield put({
      type: 'BREEDER_SLOT_TOTAL',
      total: result.data.total
    });
    yield put({
      type: 'BREEDER_SLOT_PAGE',
      pageNumber
    });
    yield put({ type: 'LOADER_HIDE' });
    // alert(1);
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    console.log(e);
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchFetchSlot() {
  yield takeEvery('FETCH_BREEDER_SLOT', fetchSlot);
}
