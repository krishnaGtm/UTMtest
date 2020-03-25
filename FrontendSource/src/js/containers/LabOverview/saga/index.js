import { takeEvery } from 'redux-saga';
import { call, put, takeLatest, select } from 'redux-saga/effects';
import axios from 'axios';
import urlConfig from '../../../urlConfig';
import { token } from '../../../saga/tokenSagas';
import {
  // noInternet,
  // notificationMsg,
  notificationSuccess
} from '../../../saga/notificationSagas';

function labOverviewApi(action, tokenKey) {
  const { year, periodID } = action;
  return axios({
    method: 'get',
    url: urlConfig.getLabOverview,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      year,
      periodID
    }
  });
}
function* labOverview(action) {
  try {
    const tokenKey = yield call(token);

    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(labOverviewApi, action, tokenKey);
    const { data } = result;
    yield put({
      type: 'LAB_OVERVIEW_DATA_ADD',
      data
    });
    yield put({
      type: 'LABOVERVIEW_REFRESH'
    });
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response.data) {
      const error = e.response.data;
      // console.log(error);
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
export function* watchLabOverview() {
  yield takeEvery('LAB_OVERVIEW_DATA_FETCH', labOverview);
}

function slotEditApi(slotID, plannedDate, expectedDate, tokenKey) {
  return axios({
    method: 'post',
    url: urlConfig.moveSlot,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    data: {
      slotID,
      plannedDate,
      expectedDate
    }
  });
}
function* slotEdit(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const tokenKey = yield call(token);
    const { slotID, plannedDate, expectedDate, currentYear } = action;
    const result = yield call(slotEditApi, slotID, plannedDate, expectedDate, tokenKey);
    const { data } = result;
    if (data) {
      yield put({
        type: 'LAB_OVERVIEW_DATA_FETCH',
        year: currentYear
      });
      // console.log('--', plannedDate, expectedDate);
      // yield put({
      //   type: 'LAB_OVERIVE_DATE_UPDATE',
      //   slotID,
      //   plannedDate,
      //   expectedDate
      // });
      const loList = yield select(state => state.laboverview.data);
      const tname = loList.filter(l => l.slotID === slotID);
      // console.log(tname, loList[0].slotName);
      yield put(notificationSuccess(`Slot ${tname[0].slotName} was successfully moved.`));
    }
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    // console.log(e);
    if (e.response.data) {
      const error = e.response.data;
      // console.log(error);
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
export function* watchLabSlotEdit() {
  yield takeLatest('SLOT_EDIT', slotEdit);
}