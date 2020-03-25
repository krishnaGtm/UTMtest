import { takeEvery } from 'redux-saga';
import { call, put } from 'redux-saga/effects';
import axios from 'axios';
import urlConfig from '../../../urlConfig';
import { token } from '../../../saga/tokenSagas';
import { noInternet, notificationMsg } from '../../../saga/notificationSagas';
import { labCapacityData, labCapacityColumn } from '../action';

function planningCapacityApi(action, tokenKey) {
  return axios({
    method: 'get',
    url: urlConfig.planingCapacity,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      year: action.year
    }
  });
}
function* planningCapacity(action) {
  try {
    const tokenKey = yield call(token);

    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(planningCapacityApi, action, tokenKey);

    const { data, columns } = result.data;
    yield put(labCapacityData(data));
    yield put(labCapacityColumn(columns));
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
  }
}
export function* watchPlanningCapacity() {
  yield takeEvery('LAB_DATA_FETCH', planningCapacity);
}

function planningUpdateApi(action, tokenKey) {
  return axios({
    method: 'post',
    url: urlConfig.postPlaningCapacity,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    data: {
      capacityList: action.data
    }
  });
}
function* planningUpdate(action) {
  // console.log(action);
  try {
    const tokenKey = yield call(token);

    yield put({ type: 'LOADER_SHOW' });
    // const result =
    yield call(planningUpdateApi, action, tokenKey);

    planningCapacity(action);

    yield put({ type: 'LOADER_HIDE' });
    // console.log(result);
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchPlanningUpdate() {
  yield takeEvery('LAB_DATA_UPDATE', planningUpdate);
}
