/**
 * Created by sushanta on 3/14/18.
 */
import { call, takeLatest, put } from 'redux-saga/effects';
import { token } from '../../../saga/tokenSagas';
import {
  getApprovalListApi,
  getPlanPeriodsApi,
  approveSlotApi,
  denySlotApi,
  updateSlotPeriodApi
} from '../api';
import { getApprovalListDone, getPlanPeriodsDone } from '../actions';
import {
  noInternet,
  notificationMsg,
  notificationSuccess
} from '../../../saga/notificationSagas';

function* getApprovalList({ periodID }) {
  try {
    const tokenKey = yield call(token);
    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(getApprovalListApi, periodID, tokenKey);
    yield put(getApprovalListDone(result.data));
    yield put({ type: 'LOADER_HIDE' });
  } catch (err) {
    yield put({ type: 'LOADER_HIDE' });
    console.log(err);
  }
}
export function* watchGetApprovalList() {
  yield takeLatest('GET_APPROVAL_LIST', getApprovalList);
}

function* getPlanPeriods() {
  try {
    const tokenKey = yield call(token);
    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(getPlanPeriodsApi, tokenKey);
    yield put(getPlanPeriodsDone(result.data));
    yield put({ type: 'LOADER_HIDE' });
  } catch (err) {
    yield put({ type: 'LOADER_HIDE' });
    console.log(err);
  }
}
export function* watchGetPlanPeriods() {
  yield takeLatest('GET_PLAN_PERIODS', getPlanPeriods);
}

function* approveSlot({ slotID, selectedPeriodID }) {
  try {
    yield put({ type: 'LOADER_SHOW' });
    const tokenKey = yield call(token);
    const result = yield call(approveSlotApi, slotID, tokenKey);
    // console.log(result);
    // return null;

    const { success, message } = result.data;
    if (success) {
      yield put(notificationSuccess(message));
      const approvalList = yield call(
        getApprovalListApi,
        selectedPeriodID,
        tokenKey
      );
      yield put(getApprovalListDone(approvalList.data));
    }
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response !== undefined) {
      if (e.response.data) {
        const { data } = e.response;
        yield put(notificationMsg(data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchSlotApproval() {
  yield takeLatest('APPROVE_SLOT', approveSlot);
}

function* denySlot({ slotID, selectedPeriodID }) {
  try {
    const tokenKey = yield call(token);
    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(denySlotApi, slotID, tokenKey);
    const { success, message } = result.data;
    if (success) {
      yield put(notificationSuccess(message));
      const approvalList = yield call(
        getApprovalListApi,
        selectedPeriodID,
        tokenKey
      );
      yield put(getApprovalListDone(approvalList.data));
    }
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response !== undefined) {
      if (e.response.data) {
        const { data } = e.response;
        yield put(notificationMsg(data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchSlotDenial() {
  yield takeLatest('DENY_SLOT', denySlot);
}

function* updateSlotPeriod({ slotID, periodID, plannedDate, expectedDate }) {
  try {
    const tokenKey = yield call(token);
    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(
      updateSlotPeriodApi,
      slotID,
      plannedDate,
      expectedDate,
      tokenKey
    );
    const { success, message } = result.data;
    if (success) {
      yield put(notificationSuccess(message));
      const approvalList = yield call(getApprovalListApi, periodID, tokenKey);
      yield put(getApprovalListDone(approvalList.data));
    }
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
    if (e.response !== undefined) {
      if (e.response.data) {
        const { data } = e.response;
        yield put(notificationMsg(data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchUpdateSlotPeriod() {
  yield takeLatest('UPDATE_SLOT_PERIOD', updateSlotPeriod);
}
