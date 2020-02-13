import { takeEvery } from 'redux-saga';
import { call, put, takeLatest, select } from 'redux-saga/effects';
import axios from 'axios';
import urlConfig from '../../../urlConfig';
import { token } from '../../../saga/tokenSagas';
import {
  periodAdd,
  displayPeriodAdd,
  displayPeriodExpected,
  breedingFomrData,
  breedingMessage,
  breedingSubmit,
  breedingForced,
  breedingReset,
  breedingMaterialType
} from '../action';
import {
  noInternet,
  notificationMsg,
  notificationSuccess
} from '../../../saga/notificationSagas';

function getBreederPageSize(store) {
  return store.slotBreeder.total.pageSize || 200;
}
function breederApi(tokenKey) {
  return axios({
    method: 'get',
    url: urlConfig.getBreeder,
    headers: {
      enzauth: tokenKey
    },
    withCredentials: true
  });
}
function* breeder() {
  try {
    const tokenKey = yield call(token);

    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(breederApi, tokenKey);

    yield put(breedingFomrData(result.data));
    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    yield put({ type: 'LOADER_HIDE' });
  }
}
export function* watchBreeder() {
  yield takeEvery('BREEDER_FIELD_FETCH', breeder);
}

function cropChangeApi(action, tokenKey) {
  return axios({
    method: 'get',
    url: urlConfig.getMaterialType,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      crop: action.crop
    }
  });
}
function* cropChange(action) {
  try {
    const tokenKey = yield call(token);
    const result = yield call(cropChangeApi, action, tokenKey);
    yield put(breedingMaterialType(result.data));
  } catch (e) {
    console.log(e);
  }
}
export function* watchCropChange() {
  yield takeLatest('BREEDER_FETCH_MATERIALTYPE', cropChange);
}

function breederReserveApi(action, tokenKey) {
  const {
    breedingStationCode,
    cropCode,
    testTypeID,
    materialTypeID,
    materialStateID,
    isolated,
    plannedDate,
    expectedDate,
    nrOfPlates,
    nrOfTests,
    forced
  } = action;
  return axios({
    method: 'post',
    url: urlConfig.postBreeder,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    data: {
      breedingStationCode,
      cropCode,
      testTypeID,
      materialTypeID,
      materialStateID,
      isolated,
      plannedDate,
      expectedDate,
      nrOfPlates,
      nrOfTests,
      forced
    }
  });
}
function* breederReserve(action) {
  try {
    const tokenKey = yield call(token);

    // console.log(action);
    // breedingStationCode
    // cropCode

    yield put({ type: 'LOADER_SHOW' });
    const result = yield call(breederReserveApi, action, tokenKey);
    const { success, message } = result.data;

    if (success) {
      const state = yield select();
      const pageSize = getBreederPageSize(state);
      // Refetch table data after success
      const { breedingStationCode: brStationCode, cropCode } = action;
      yield put({
        type: 'FETCH_BREEDER_SLOT',
        cropCode,
        brStationCode,
        pageNumber: 1,
        pageSize,
        filter: []
      });

      yield put(notificationSuccess(message));
      yield put(breedingMessage(''));
      yield put(breedingSubmit(true));
      yield put(breedingForced(false));
      yield put(breedingReset());
    } else {
      yield put(breedingMessage(message));
      yield put(breedingSubmit(false));
      yield put(breedingForced(true));
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
export function* watchBreederReserve() {
  yield takeEvery('BREEDER_RESERVE', breederReserve);
}

function periodApi(action, tokenKey) {
  // console.log(action);
  return axios({
    method: 'get',
    url: urlConfig.getPeriod,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      args: action.period
    }
  });
}
function* period(action) {
  try {
    const tokenKey = yield call(token);

    const result = yield call(periodApi, action, tokenKey);
    const { displayPeriod } = result.data;
    if (action.period === 1) {
      yield put(displayPeriodAdd(displayPeriod));
    } else {
      yield put(displayPeriodExpected(displayPeriod));
    }
  } catch (e) {
    console.log(e);
  }
}
export function* watchPeriod() {
  yield takeEvery('PERIOD_FETCH', period);
}

function plantsTestsApi(action, tokenKey) {
  // getPlatestTest
  const { plannedDate, cropCode, materialTypeID, isolated } = action;
  // console.log(action);
  return axios({
    method: 'get',
    url: urlConfig.getPlatestTest,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      plannedDate,
      cropCode,
      materialTypeID,
      isolated
    }
  });
}
function* plantsTests(action) {
  try {
    const tokenKey = yield call(token);

    const result = yield call(plantsTestsApi, action, tokenKey);
    if (result.status === 200) {
      const {
        availPlates,
        availTests,
        displayExpectedWeek,
        displayPlannedWeek,
        expectedDate
      } = result.data;

      const obj = {
        planned: displayPlannedWeek,
        expected: displayExpectedWeek,
        availPlates,
        availTests,
        expectedDate
      };

      yield put(periodAdd(obj));
    }
  } catch (e) {
    console.log(e);
  }
}
export function* watchPlantsTests() {
  yield takeEvery('PLATES_TESTS_FETCH', plantsTests);
}

function slotDeleteApi(slotID, tokenKey) {
   return axios({
    method: 'post',
    url: urlConfig.deleteSlot,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      slotID
    }
  });
}
function* slotDelete(action) {
  try {
    yield put({ type: 'LOADER_SHOW' });

    const tokenKey = yield call(token);
    const { slotID, cropCode, brStationCode, slotName } = action;
    // console.log(action);

    const result = yield call(slotDeleteApi, slotID, tokenKey);
    // console.log(result.data);
    if (result.data) {
      // delete success fetch again and reirect to page 1
      const state = yield select();
      const pageSize = getBreederPageSize(state);
      yield put({
        type: 'FETCH_BREEDER_SLOT',
        cropCode,
        brStationCode,
        pageNumber: 1,
        pageSize,
        filter: []
      });

      yield put(notificationSuccess(`Slot ${slotName} deleted successfully.`));
    }

    yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    // console.log(e);
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
export function* watchSlotDelete() {
  yield takeLatest('SLOT_DELETE', slotDelete);
}
