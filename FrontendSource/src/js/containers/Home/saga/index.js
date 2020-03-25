import { call, takeLatest, put, select } from 'redux-saga/effects';
import { noInternet, notificationMsg, notificationSuccess } from '../../../saga/notificationSagas';
import {
  fetchFileListApi,
  fetchTestTypeApi,
  fetchMaterialTypeApi,
  fetchMaterialStateApi,
  fetchContainerTypeApi,
  fetchAssignDataApi,
  fetchAssignFilterDataApi,
  fetchBreedingApi,
  fetchImportSourceApi,
  postSaveNrOfSamplesApi,
  postDeleteTestApi,
} from '../api/index';
import { token } from '../../../saga/tokenSagas';

import { show, hide } from '../../../helpers/helper';

function* fetchTestType(action) {
  try {
    yield put(show('fetchTestType'));
    yield call(token);
    const result = yield call(fetchTestTypeApi);
    const { data } = result;
    yield put({ type: 'TESTTYPE_ADD', data });

    // if testType is not selected :: default to first test
    if (action.testTypeID === '') {
      yield put({
        type: 'TESTTYPE_SELECTED',
        id: data[0].testTypeID
      });
    }
    yield put(hide('fetchTestType'));
  } catch (e) {
    yield put(hide('fetchTestType'));
    yield put(noInternet);
  }
}
export function* watchFetchTestType() {
  yield takeLatest('FETCH_TESTTYPE', fetchTestType);
}

function* fetchMaterialType() {
  try {
    yield put(show('fetchMaterialType'));
    yield call(token);
    const result = yield call(fetchMaterialTypeApi);
    const { data } = result;
    if (result.status === 200) {
      yield put({ type: 'STORE_MATERIAL_TYPE', data });
    }
    yield put(hide('fetchMaterialType'));
  } catch (e) {
    yield put(hide('fetchMaterialType'));
    yield put(noInternet);
  }
}
export function* watchFetchMaterialType() {
  yield takeLatest('FETCH_MATERIAL_TYPE', fetchMaterialType);
}

function* fetchMaterialState() {
  try {
    yield put(show('fetchMaterialState'));
    yield call(token);
    const result = yield call(fetchMaterialStateApi);
    const { data, status } = result;
    if (status === 200) {
      yield put({ type: 'STORE_MATERIAL_STATE', data });
    }
    yield put(hide('fetchMaterialState'));
  } catch (e) {
    yield put(hide('fetchMaterialState'));
    yield put(noInternet);
  }
}
export function* watchFetchMaterialState() {
  yield takeLatest('FETCH_MATERIAL_STATE', fetchMaterialState);
}

function* fetchContainerType() {
  try {
    yield put(show('fetchContainerType'));
    yield call(token);
    const result = yield call(fetchContainerTypeApi);
    const { data, status } = result;
    if (status === 200) {
      yield put({ type: 'STORE_CONTAINER_TYPE', data });
    }
    yield put(hide('fetchContainerType'));
  } catch (e) {
    yield put(hide('fetchContainerType'));
    yield put(noInternet);
  }
}
export function* watchFetchContainerType() {
  yield takeLatest('FETCH_CONTAINER_TYPE', fetchContainerType);
}

function* fetchAssignData(action) {
  try {
    yield put(show('fetchAssignData'));
    yield call(token);
    const result = yield call(fetchAssignDataApi, action.file);

    const { data } = result[0];
    const markers = result[1].data;

    if (data.success) {
      // clear filter,
      yield put({ type: 'FILTER_CLEAR'});
      yield put({ type: 'DATA_BULK_ADD', data: data.dataResult.data });
      yield put({ type: 'COLUMN_BULK_ADD', data: data.dataResult.columns });
      yield put({ type: 'TOTAL_RECORD', total: data.total });
      yield put({ type: 'PAGE_RECORD', pageNumber: action.file.pageNumber });
      yield put({ type: 'TESTTYPE_SELECTED', id: action.file.testTypeID });
    }
    const newMarker = markers.map(d => ({ ...d, selected: false }));
    yield put({ type: 'MARKER_BULK_ADD', data: newMarker });
    yield put({ type: 'SAMPLE_NUMBER_REST' });

    yield put(hide('fetchAssignData'));
  } catch (e) {
    yield put(hide('fetchAssignData'));
    // make blank when get error in fetch data
    yield put({ type: 'MARKER_BULK_ADD', data: [] });
    yield put({ type: 'DATA_BULK_ADD', data: [] });
    yield put({ type: 'COLUMN_BULK_ADD', data: [] });
    yield put({ type: 'TOTAL_RECORD', total: 0 });
    yield put(noInternet);
  }
}
export function* watchFetchAssignData() {
  yield takeLatest('ASSIGNDATA_FETCH', fetchAssignData);
}

function* fetchAssignFilterData(action) {
  try {
    yield put(show('fetchAssignFilterData'));
    yield call(token);
    const result = yield call(fetchAssignFilterDataApi, action);
    const { data } = result;
    if (data.success) {
      yield put({
        type: 'DATA_BULK_ADD',
        data: data.dataResult.data
      });
      yield put({
        type: 'COLUMN_BULK_ADD',
        data: data.dataResult.columns
      });
      yield put({
        type: 'TOTAL_RECORD',
        total: data.total
      });
      yield put({
        type: 'PAGE_RECORD',
        pageNumber: 1
      });
    }
    yield put(hide('fetchAssignFilterData'));
  } catch (e) {
    yield put(hide('fetchAssignFilterData'));
  }
}
export function* watchFetchAssignFilterData() {
  yield takeLatest('FETCH_FILTERED_DATA', fetchAssignFilterData);
}

function* fetchAssignClearData(action) {
  try {
    yield put(show('fetchAssignClearData'));
    yield call(token);
    const result = yield call(fetchAssignFilterDataApi, action);
    const { data } = result;
    if (data.success) {
      yield put({ type: 'DATA_BULK_ADD', data: data.dataResult.data });
      yield put({ type: 'COLUMN_BULK_ADD', data: data.dataResult.columns });
      yield put({ type: 'TOTAL_RECORD', total: data.total });
      yield put({ type: 'FILTER_CLEAR'});
      // changeing page to one
      yield put({ type: 'PAGE_RECORD', pageNumber: 1 });
    }

    yield put(hide('fetchAssignClearData'));
  } catch (e) {
    yield put(hide('fetchAssignClearData'));
  }
}
export function* watchFetchAssignClearData() {
  yield takeLatest('FETCH_CLEAR_FILTER_DATA', fetchAssignClearData);
}

function* fetchFileList(action) {
  try {
    // yield put(show('fetchFileList'));
    yield call(token);
    const { breeding, crop } = action;
    const result = yield call(fetchFileListApi, breeding, crop);

    // TODO :: check impack and imporve
    // clear data or not
    // if (action.empty === false) {
    // }
    /*
    if (action.empty !== false) {
      yield put({  type: 'DATA_BULK_ADD', data: [] });
      yield put({  type: 'COLUMN_BULK_ADD', data: [] });
    }
    */
    yield put({ type: 'FILELIST_ADD', data: result.data });
    // yield put(hide('fetchFileList'));
  } catch (e) {
    // yield put(hide('fetchFileList'));
    yield put(noInternet);
  }
}
export function* watchFetchFileList() {
  yield takeLatest('FILELIST_FETCH', fetchFileList);
}

function* fetchBreeding() {
  try {
    yield put(show('fetchBreeding'));
    yield call(token);
    const result = yield call(fetchBreedingApi);

    yield put({
      type: 'BREEDING_STATION_STORE',
      data: result.data
    });

    yield put(hide('fetchBreeding'));
  } catch (e) {
    yield put(hide('fetchBreeding'));
    yield put(noInternet);
  }
}
export function* watchFetchBreeding() {
  yield takeLatest('FETCH_BREEDING_STATION', fetchBreeding);
}

function* fetchImportSource() {
  try {
    yield put(show('fetchImportSource'));
    yield call(token);
    const result = yield call(fetchImportSourceApi);
    if (result.status === 200) {
      yield put({ type: 'ADD_SOURCE', data: result.data });
    }
    yield put(hide('fetchImportSource'));
  } catch (e) {
    yield put(hide('fetchImportSource'));
    yield put(noInternet);
  }
}
export function* watchFetchImportSource() {
  yield takeLatest('FETCH_IMPORTSOURCE', fetchImportSource);
}

function* postSaveNrOfSamples(action) {
  try {
    // const fileID = yield select(state => state.rootTestID.testID);
    const fileID = yield select(state => state.assignMarker.file.selected.fileID);
    const noofsamples = yield select(state => state.assignMarker.numberOfSamples.samples);
    // console.log('fileID', fileID, 'noofsamples', noofsamples);
    const samples =  [];
    noofsamples.map(row => {
      const { materialID, nrOfSample, changed } = row;
      if (changed) {
        samples.push({ materialID, nrOfSample });
      }
      return null;
    })
    // console.log('samples', samples);

    const result = yield call(postSaveNrOfSamplesApi, { fileID, samples });
    // console.log('saga/index.js', result);
    if (result.data) {
      yield put({ type: 'SAMPLE_NUMBER_CHANGE_FALSE' });
    }
  } catch (e) {
    if (e.response.data) {
      const error = e.response.data;
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
export function* watchpostSaveNrOfSamples() {
  yield takeLatest('POST_NO_OF_SAMPLES', postSaveNrOfSamples)
}

/**
 * Saga
 */
function* postDeleteTest(action) {
  try {
    // yield put(show());
    const result = yield call(postDeleteTestApi, action.testID);

    if (result.data) {
      // ## remove table date
      yield put({type: 'RESETALL'});
      // ## remove filed from imported dropdown list
      yield put({
        type: 'REMOVE_FILE_AFTER_DELETE',
        testID: action.testID
      });
    }
    // yield put(hide());

    yield put(notificationSuccess(result.data));
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
export function* watchDeletePost() {
  yield takeLatest('POST_DELETE_TEST', postDeleteTest);
}
