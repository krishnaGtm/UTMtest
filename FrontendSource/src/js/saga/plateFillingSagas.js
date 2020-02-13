/**
 * Created by sushanta on 3/5/18.
 */
import { call, put, takeLatest, select } from 'redux-saga/effects';
import axios from 'axios';
import urlConfig from '../urlConfig';
import {
  noInternet,
  notificationMsg,
  notificationSuccess
} from './notificationSagas';
import { token } from './tokenSagas';

function getPlateFillingPageSize(store) {
  return store.plateFilling.total.pageSize || 200;
}

function createReplicaApi(data) {
  return axios({
    method: 'patch',
    url: urlConfig.replicateMaterials,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
}
function* createReplica({ data }) {
  try {
    yield call(token);

    // yield put({ type: 'LOADER_SHOW' });
    const response = yield call(createReplicaApi, data);
    if (response.status === 200) {
      // yield put({ type: 'LOADER_HIDE' });
      // TODO change in pageSize
      const state = yield select();
      const pageSize = getPlateFillingPageSize(state);

      yield put({
        type: 'PLATEDATA_FETCH',
        testID: data.testID,
        pageNumber: 1,
        pageSize,
        filter: []
      });
      yield put({ type: 'SIZE_PLATE_RECORD', pageSize });
    } else {
      // yield put({ type: 'LOADER_HIDE' });
      yield put(
        notificationMsg({
          message: 'Replicas could not be created. Try Again Later'
        })
      );
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
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
export function* watchCreateReplicaDispatch() {
  yield takeLatest('CREATE_REPLICA', createReplica);
}

function deleteDeadMaterialsApi(action) {
  return axios({
    method: 'delete',
    url: urlConfig.deleteDeadMaterials,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID
    }
  });
}
function* deleteDeadMaterials(action) {
  try {
    yield call(token);

    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(deleteDeadMaterialsApi, action);
    if (result.data) {
      // yield put({ type: 'LOADER_HIDE' });
      // TODO change in pageSize
      const state = yield select();
      const pageSize = getPlateFillingPageSize(state);
      yield put({
        type: 'PLATEDATA_FETCH',
        testID: action.testID,
        pageNumber: 1,
        pageSize,
        filter: []
      });
      yield put({ type: 'SIZE_PLATE_RECORD', pageSize});
    } else {
      // yield put({ type: 'LOADER_HIDE' });
      yield put(
        notificationMsg({
          message: 'Dead Materials could not be removed. Try Again Later'
        })
      );
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
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
export function* watchDeleteDeadMaterialsDispatch() {
  yield takeLatest('REQUEST_DEAD_MATERIALS_DELETE', deleteDeadMaterials);
}

function fetchWellApi(action) {
  return axios({
    method: 'get',
    url: urlConfig.getWellPosition,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      testID: action.testID
    }
  });
}
export function* fetchWell(action) {
  try {
    yield call(token);

    const result = yield call(fetchWellApi, action);
    yield put({
      type: 'WELL_ADD',
      data: result.data
    });
  } catch (e) {
    // console.log(e);
  }
}
export function* watchFetchWell() {
  yield takeLatest('FETCH_WELL', fetchWell);
}

function getStatusListApi() {
  return axios({
    method: 'get',
    url: urlConfig.getStatusList,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    }
  });
}
export function* wetchStatusList() {
  try {
    yield call(token);

    const result = yield call(getStatusListApi);
    if (result.data) {
      yield put({
        type: 'STORE_STATUS',
        data: result.data
      });
    }
  } catch (e) {
    // console.log(e);
  }
}
export function* watchFetchStatusList() {
  yield takeLatest('FETCH_STATULSLIST', wetchStatusList);
}

export function fetchPlateDataApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.getDetermination,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      filter: action.filter,
      pageNumber: action.pageNumber,
      pageSize: action.pageSize
    }
  });
}
function* fetchPlateData(action) {
  // console.log(action);
  try {
    // yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    const result = yield call(fetchPlateDataApi, action);
    // console.log(action,' --- plateFillingSage');

    const { data } = result;
    // const state = yield select();

    yield put({
      type: 'DATA_FILLING_BULK_ADD',
      data: data.data.data
    });
    yield put({
      type: 'COLUMN_FILLING_BULK_ADD',
      data: data.data.columns
    });
    yield put({
      type: 'TOTAL_PLATE_RECORD',
      total: data.total
    });
    yield put({
      type: 'SIZE_PLATE_RECORD',
      pageSize: action.pageSize
    });
    yield put({
      type: 'PAGE_PLATE_RECORD',
      pageNumber: action.pageNumber
    });

    const state = yield select();
    // console.log(state.loader);
    // yield put({ type: 'LOADER_HIDE' });
    // console.log(state.loader);

    /**
     * TODO below line is quick fix loader set to zero
     * need to check why its not changing itself to zero
     */
    yield put({ type: 'LOADER_RESET' });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put({
      type: 'DATA_FILLING_BULK_ADD',
      data: []
    });
    yield put({
      type: 'COLUMN_FILLING_BULK_ADD',
      data: []
    });
    yield put({
      type: 'TOTAL_PLATE_RECORD',
      total: 0
    });
    yield put(noInternet);
  }
}
export function* watchFetchPlateData() {
  yield takeLatest('PLATEDATA_FETCH', fetchPlateData);
}

function deleteRowApi(action) {
  return axios({
    method: 'delete',
    url: urlConfig.delMaterials,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      wellIDs: action.wellIDs
    }
  });
}
function* deleteRow(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    // console.log(action.materialID);
    const result = yield call(deleteRowApi, action);
    if (result.data) {
      yield put({
        type: 'DATA_ROW_DELETE',
        wellIDs: action.wellIDs,
        testID: action.testID,
        wellTypeID: result.data.wellTypeID
      });
      yield put({
        type: 'ROOT_STATUS',
        statusCode: result.data.statusCode
      });
    }
    // yield put({ type: 'LOADER_HIDE' });
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
export function* watchDeleteRow() {
  yield takeLatest('REQUEST_DATA_DELETE', deleteRow);
}

function undoDeadApi(action) {
  return axios({
    method: 'delete',
    url: urlConfig.delMaterialsUndo,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      wellIDs: action.wellIDs
    }
  });
}
function* undoDead(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    const result = yield call(undoDeadApi, action);

    if (result.status === 200) {
      yield put({
        type: 'DATA_UNDO_DEAD',
        wellIDs: action.wellIDs,
        testID: action.testID,
        wellTypeID: result.data.wellTypeID
      });
    }
    // yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
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
export function* watchUndoDead() {
  yield takeLatest('REQUEST_UNDO_DELETE', undoDead);
}

function deleteReplicateApi(action) {
  return axios({
    method: 'delete',
    url: urlConfig.delDeleteReplicate,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      materialID: action.materialID,
      wellID: action.wellID
    }
  });
}
function* deleteReplicate(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    // console.log(action);
    const result = yield call(deleteReplicateApi, action);
    // console.log(result);

    if (result) {
      // const crop = yield select(state => state.user.selectedCrop || '');
      // const breedingStation = yield select(state => state.breedingStation.selected || '');
      // console.log(crop, breedingStation);
      const testID = yield select(state => state.plateFilling.testsLookup.selected.testID);
      const wellsPerPlate = yield select(state => state.plateFilling.testsLookup.selected.wellsPerPlate);

      const fetchresult = yield call(fetchPlateDataApi, {
        testID: testID * 1,
        filter: [],
        pageNumber: 1,
        pageSize: wellsPerPlate
      });
      // console.log(fetchresult);

      const { data } = fetchresult;
      // const state = yield select();

      yield put({
        type: 'DATA_FILLING_BULK_ADD',
        data: data.data.data
      });
      yield put({
        type: 'COLUMN_FILLING_BULK_ADD',
        data: data.data.columns
      });
      yield put({
        type: 'TOTAL_PLATE_RECORD',
        total: data.total
      });
      yield put({
        type: 'SIZE_PLATE_RECORD',
        pageSize: wellsPerPlate
      });
      yield put({
        type: 'PAGE_PLATE_RECORD',
        pageNumber: 1
      });
      // yield put({
      //   type: 'DATA_REMOVE_REPLICA',
      //   wellID: action.wellID
      // });
    }
    // yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    console.log(e);
    // yield put({ type: 'LOADER_HIDE' });
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
export function* watchDeleteReplicate() {
  yield takeLatest('REQUEST_DELETE_REPLICATE', deleteReplicate);
}

function getWellTypeApi() {
  return axios({
    method: 'get',
    url: urlConfig.getWellType,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}
export function* fetchWellType() {
  try {
    yield call(token);
    yield put({
      // type: 'LOADER_SHOW'
    });
    const result = yield call(getWellTypeApi);
    yield put({
      type: 'STORE_WELLTYPEID',
      data: result.data
    });
    // yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    console.log(e);
  }
}
export function* watchFetchWellType() {
  yield takeLatest('FETCH_GETWELLTYPEID', fetchWellType);
}

function saveDBApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.postWellSaveDB,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      materialWell: action.materialIDs
    }
  });
}
function* saveDB(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(saveDBApi, action);
    const { data } = result;

    // yield put({ type: 'LOADER_HIDE' });
    if (data) {
      yield put(notificationSuccess('Save to DB was success.'));
    } else {
      yield put(noInternet);
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put(notificationMsg(e.response.data));
  }
}
export function* watchActionSaveDB() {
  yield takeLatest('ACTION_SAVE_DB', saveDB);
}

function reservePlateApi(action) {
  // console.log(action);
  return axios({
    method: 'post',
    url: urlConfig.postReservePlate,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID
    }
  });
}
function* reservePlate(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(reservePlateApi, action);
    yield put({
      type: 'ROOT_STATUS',
      statusCode: result.data.statusCode,
      testID: action.testID
    });
    // yield put({ type: 'LOADER_HIDE' });
    yield put(notificationSuccess('Confirm request successfully.'));
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
export function* watchReservePlate() {
  yield takeLatest('REQUEST_RESERVE_PLATE', reservePlate);
}
function undoFixedPositionApi(action) {
  const data = { ...action };
  delete data.type;
  // console.log(data);
  return axios({
    method: 'post',
    url: urlConfig.postUndoFixedPosition,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
}
function* undoFixedPosition(action) {
  try {
    const pageSize = yield select(state => state.plateFilling.total.pageSize);
    const result = yield call(undoFixedPositionApi, action);

    if (result.data) {
      // service return only true
      yield put({
        type: 'PAGE_PLATE_RECORD',
        pageNumber: 1
      });
      yield put({
        type: 'PLATEDATA_FETCH',
        testID: action.testID,
        filter: [],
        pageNumber: 1,
        pageSize
      });
      yield put({
        type: 'FETCH_WELL',
        testID: action.testID
      });

      yield put(notificationSuccess('Success, Undo fixed position.'));
    }
  } catch (e) {
    // console.log(e);
    yield put(notificationMsg(e.response.data));
  }
}
export function* watchUndoFixedPosition() {
  yield takeLatest('REQUEST_UNDO_FIXEDPOSITION', undoFixedPosition);
}
