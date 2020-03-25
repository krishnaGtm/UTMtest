import { call, takeLatest, put } from 'redux-saga/effects';
import { token } from '../../saga/tokenSagas';
import { noInternet, notificationSuccess, notificationMsg } from '../../saga/notificationSagas';

import { getPlatPlanApi } from './api';
import {
  FETCH_PLAT_PLAN,
  FILTER_PLAT_PLAN_ADD,

  FILTER_PLAT_PLAN_RESET,

  PLAT_PLAN_BULK,
  PLAT_PLAN_RECORDS,
  PLAT_PLAN_PAGE
} from './constant';
import { storeCrops } from './action';

function* getPlatPlan(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const { pageNumber, pageSize, filter } = action;
    yield call(token);

    const result = yield call(getPlatPlanApi, pageNumber, pageSize, filter);

    const { total, data } = result.data;

    yield put({
      type: PLAT_PLAN_BULK,
      data: data
    });
    yield put({
      type: PLAT_PLAN_RECORDS,
      total
    });
    yield put({
      type: PLAT_PLAN_PAGE,
      pageNumber: pageNumber
    });
    yield put({ type: 'LOADER_HIDE' });
    // yield put(storeCrops(result.data));
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    // console.log(e.response);
    /**
     * I am getting this error
     * @type {[type]}
     * data: {errorType: 1, code: "1218375", message: "There is no row at position 0."}
     * so i am just empthing data
     */
    yield put({ type: PLAT_PLAN_BULK, data: [] });
    yield put({ type: PLAT_PLAN_RECORDS, total: 0 });
    yield put({ type: PLAT_PLAN_PAGE, pageNumber: 1 });
    /*if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }*/
  }
}
export function* watchGetPlatPlan() {
  yield takeLatest(FETCH_PLAT_PLAN, getPlatPlan)
}