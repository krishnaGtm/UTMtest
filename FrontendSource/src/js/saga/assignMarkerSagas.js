import { takeEvery } from 'redux-saga';
import { call, put, takeLatest, select } from 'redux-saga/effects';
import axios from 'axios';
import urlConfig from '../urlConfig';
import { token } from './tokenSagas';
import {
  notificationSuccess,
  notificationMsg,
  notificationGeneric
} from './notificationSagas';
import { show, hide } from '../helpers/helper';

function fetchMaterialsApi(action) {
  const data = { ...action };
  delete data.type;
  return axios({
    method: 'post',
    url: urlConfig.getMaterials,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
}
function* fetchMaterials(action) {
  try {
    yield call(token);
    yield put(show('fetchMaterials'));
    const result = yield call(fetchMaterialsApi, action);
    // console.log(result);
    if (result.data) {
      const markerMaterialMap = {};
      const samples = [];

      const determinations =
        result.data.data.columns &&
        result.data.data.columns.filter(
          col =>
            col.traitID && col.traitID.substring(0, 2).toLowerCase() === 'd_'
        );
      const determinationColumns = determinations.map(col =>
        col.traitID.toLowerCase()
      );
      result.data.data.data.forEach(row => {
        // state NumberOfSamples
        samples.push({
          materialID: row.materialID,
          nrOfSample: row.nrOfSamples,
          changed: false
        });
        determinationColumns.forEach(col => {
          markerMaterialMap[`${row.materialID}-${col}`] = {
            originalState: row[col],
            changed: false,
            newState: row[col]
          };
        });
      });

      // number of sample
      yield put({ type: 'SAMPLE_NUMBER', samples });
      yield put({
        type: 'FETCH_MATERIALS_SUCCEEDED',
        materials: result.data,
        markerMaterialMap
      });
    }

    yield put(hide('fetchMaterials'));
  } catch (e) {
    // console.log(e);

    yield put(hide('fetchMaterials'));
    yield put({ type: 'FETCH_MATERIALS_FAILED'});
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
export function* watchFetchMaterials() {
  yield takeEvery('FETCH_MATERIALS', fetchMaterials);
}

function fetchMaterialsWithDeterminationsForExternalTestApi(action) {
  // console.log(action);
  const data = { ...action };
  delete data.type;
  return axios({
    method: 'post',
    url: urlConfig.getMaterialsWithDeterminationsForExternalTest,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
  // return true;
}
function* fetchMaterialsWithDeterminationsForExternalTest(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(
      fetchMaterialsWithDeterminationsForExternalTestApi,
      action
    );
    // yield put({ type: 'LOADER_HIDE' });
    if (result.data) {
      const markerMaterialMap = {};
      const numberOfSample = [];
      const determinations =
        result.data.data.columns &&
        result.data.data.columns.filter(
          col =>
            col.traitID && col.traitID.substring(0, 2).toLowerCase() === 'd_'
        );

      const determinationColumns = determinations.map(col =>
        col.traitID.toLowerCase()
      );
      result.data.data.data.forEach(row => {
        determinationColumns.forEach(col => {
          console.log('col', col);
          markerMaterialMap[`${row.materialID}-${col}`] = {
            originalState: row[col],
            changed: false,
            newState: row[col]
          };
        });
      });
      yield put({
        type: 'FETCH_MATERIALS_SUCCEEDED',
        materials: result.data,
        markerMaterialMap
      });
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });

    yield put({ type: 'FETCH_MATERIALS_FAILED'});
  }
}
export function* watchFetchMaterialsWithDeterminationsForExternalTest() {
  yield takeEvery(
    'FETCH_MATERIAL_EXTERNAL',
    fetchMaterialsWithDeterminationsForExternalTest
  );
}

export function* watchFetchFilteredMaterials() {
  yield takeEvery('FETCH_FILTERED_MATERIAL', fetchMaterials);
}

function updateTestAttributesApi(attributes) {
  return axios({
    method: 'post',
    url: urlConfig.updateTestAttributes,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: attributes
  });
}
function* updateTestAttributes({ attributes }) {
  // console.log(attributes);
  // return null;
  try {
    yield call(token);
    // console.log(attributes);
    // return null;
    yield put(show('updateTestAttributes'));
    const response = yield call(updateTestAttributesApi, attributes);

    if (response.status === 200) {
      yield put({type: 'SELECT_MATERIAL_TYPE', id: attributes.materialTypeID });
      yield put({type: 'SELECT_MATERIAL_STATE', id: attributes.materialStateID });
      yield put({type: 'SELECT_CONTAINER_TYPE', id: attributes.containerTypeID });
      yield put({type: 'CHANGE_ISOLATION_STATUS', isolationStatus: attributes.isolated });
      yield put({type: 'CHANGE_CUMULATE_STATUS', cumulate: attributes.cumulate });
      yield put({ type: 'TESTTYPE_SELECTED', id: attributes.testTypeID });
      yield put({ type: 'ROOT_TESTTYPEID', testTypeID: attributes.testTypeID });
      yield put({type: 'CHANGE_PLANNED_DATE', plannedDate: attributes.plannedDate });
      yield put({type: 'CHANGE_EXPECTED_DATE', expectedDate: attributes.expectedDate });
      yield put({
        type: 'FILELIST_FETCH',
        breeding: attributes.breeding,
        crop: attributes.cropCode,
        empty: false
      });
      if (attributes.determinationRequired) {
        yield put({
          type: 'FETCH_MARKERLIST',
          testID: attributes.testID,
          cropCode: attributes.cropCode,
          testTypeID: attributes.testTypeID
        });
      } else {
        // console.log('Reset_marker_List');
        yield put({ type: 'RESET_MARKER_LIST' });
      }

      yield put(notificationSuccess('Test Attributes updated successfully.'));
      // yield put({ type: 'LOADER_HIDE ' });
    } else {
      yield put({ type: 'UPDATE_ATTRIBUTES_FAILURE' });
      // yield put({ type: 'LOADER_HIDE ' });
      yield put(
        notificationMsg({
          message: 'Test Attributes could not be updated now. Try Again Later'
        })
      );
    }
    yield put(hide('updateTestAttributes'));
  } catch (e) {
    yield put(hide('updateTestAttributes'));
    // yield put({ type: 'LOADER_HIDE' });
    yield put({ type: 'UPDATE_ATTRIBUTES_FAILURE' });
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
    // yield put(notificationMsg({ message: 'Test Attributes could not be updated now. Try Again Later' }));
  }
}
export function* watchUpdateTestAttributesDispatch() {
  yield takeLatest('UPDATE_TEST_ATTRIBUTES', updateTestAttributes);
}

function saveMaterialMarkerApi(action) {
  const data = {...action.materialsMarkers};
  return axios({
    method: 'post',
    url: urlConfig.saveDeterminations,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
}
function* saveMaterialMarker(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(saveMaterialMarkerApi, action);
    // yield put({ type: 'LOADER_HIDE' });
    if (result.data) {
      yield put({
        type: 'MATERIALS_MARKER_SAVE_SUCCEEDED'
      });
      // console.log(result.data);
      yield put({
        type: 'ROOT_STATUS',
        statusCode: result.data.statusCode
      });
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put({type: 'FETCH_MATERIALS_FAILED'});
  }
}
export function* watchSaveMaterialMarker() {
  yield takeEvery('SAVE_MATERIAL_MARKER', saveMaterialMarker);
}

function assignMarkerApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.postMarkers,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      testTypeID: action.testTypeID,
      determinations: action.determinations,
      filter: action.filter
    }
  });
}
function* assignMarker(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(assignMarkerApi, action);
    // yield put({ type: 'LOADER_HIDE' });
    if (result.data) {
      // console.log(result.data);
      yield put({
        type: 'ROOT_STATUS',
        statusCode: result.data.statusCode
      });
      yield put(notificationSuccess('Markers are successfully assigned.'));
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put(notificationGeneric());
  }
}
export function* watchAssignMarker() {
  yield takeEvery('ASSIGN_MARKERLIST', assignMarker);
}

function addToThreeGBApi(action) {
  // console.log(urlConfig.postAddToThreeGB, action);
  return axios({
    method: 'post',
    url: urlConfig.postAddToThreeGB,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      filter: action.filter
    }
  });
  // return true;
}
function* addToThreeGB(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(addToThreeGBApi, action);
    yield put({ type: 'FILTER_CLEAR' });
    // console.log(result, action);
    // yield put({ type: 'LOADER_HIDE' });
    if (result.data) {
      yield put(notificationSuccess('Successfully added.'));
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    // console.log(e);
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
export function* watchAddToThreeGB() {
  yield takeLatest('ADD_TO_THREEGB', addToThreeGB);
}

function fatchThreeGBApi(action) {
  // console.log('api', action);
  const data = {...action};
  delete data.type;
  // console.log(data);
  return axios({
    method: 'post',
    url: urlConfig.postGetThreeGBmaterial,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
}
function* fetchThreeGB(action) {
  // console.log('action', action);
  try {
    yield call(token);
    // yield put({type: 'LOADER_SHOW'});
    const result = yield call(fatchThreeGBApi, action);
    // yield put({ type: 'LOADER_HIDE' });
    // console.log('11 = ', result);
    if (result.data) {
      const markerMaterialMap = {};
      // alert(111);
      // console.log(result.data.data.data);
      result.data.data.data.forEach(row => {
        // console.log(row.d_TO3GB);
        markerMaterialMap[`${row.materialKey}-d_To3GB`] = {
        // markerMaterialMap[`${row.materialKey}-d_Selected`] = {
          originalState: row.d_To3GB ? 1 : 0,
          changed: false,
          newState: row.d_To3GB ? 1 : 0
        };
      });
      yield put({
        type: 'FETCH_MATERIALS_SUCCEEDED',
        materials: result.data,
        markerMaterialMap
      });
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put({ type: 'FETCH_MATERIALS_FAILED' });
  }
  /* try {
    const result = yield call(fatchThreeGBApi, action);
    console.log(result);
  } catch (e) {
    console.log(e);
  } */
}
export function* watchFetchThreeGB() {
  yield takeLatest('FETCH_THREEGB', fetchThreeGB);
}

function save3GBMarkerApi(action) {
  // console.log(action);
  return axios({
    method: 'post',
    url: urlConfig.postAddToThreeGB,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      materialSelected: action.materialWithMarker
    }
  });
  // return true;
}
export function* fetchSave3GBMarker(action) {
  try {
    yield call(token);
    // yield put({type: 'LOADER_SHOW'});
    const result = yield call(save3GBMarkerApi, action.materialsMarkers);
    // yield put({ type: 'LOADER_HIDE' });
    if (result.data) {
      yield put({
        type: 'MATERIALS_MARKER_SAVE_SUCCEEDED'
      });
      // console.log(result.data);
    }
  } catch (e) {
    console.log(e);
    // yield put({type: 'LOADER_HIDE'});

    yield put({
      type: 'FETCH_MATERIALS_FAILED'
    });
  }
}
export function* watchSave3GBmarker() {
  yield takeLatest('SAVE_3GB_MATERIAL_MARKER', fetchSave3GBMarker);
}
