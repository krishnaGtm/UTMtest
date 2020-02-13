import { takeEvery, delay } from 'redux-saga';
import { all, call, put, takeLatest, select } from 'redux-saga/effects'; // take
import axios from 'axios';
import urlConfig from '../urlConfig';

import { token, watchToken } from './tokenSagas';
import { watchFetchGetExternalTests, watchExportTest } from '../components/Export/saga';

import {
  watchGetSlotList,
  watchPostLinkSlotTest
} from '../components/Slot/saga';
import {
  watchFetchMaterials,
  watchFetchMaterialsWithDeterminationsForExternalTest,
  watchUpdateTestAttributesDispatch,
  watchFetchFilteredMaterials,
  watchSaveMaterialMarker,
  watchAssignMarker,
  watchAddToThreeGB,
  watchFetchThreeGB,
  watchSave3GBmarker
} from './assignMarkerSagas';
// fetchWellType, wetchStatusList,
import {
  watchCreateReplicaDispatch,
  watchDeleteDeadMaterialsDispatch,
  watchFetchStatusList,
  watchFetchPlateData,
  watchDeleteRow,
  fetchPlateDataApi,
  watchActionSaveDB,
  watchReservePlate,
  watchUndoDead,
  watchDeleteReplicate,
  watchUndoFixedPosition,
  watchFetchWellType,
  watchFetchWell
} from '../containers/PlateFilling/saga';
// import { watchFetchWellType, watchFetchWell } from '../containers/PlateFilling/saga';
import { fetchAssignFilterDataApi } from '../containers/Home/api';
import {
  watchBreeder,
  watchCropChange,
  watchBreederReserve,
  watchPeriod,
  watchPlantsTests,
  watchSlotDelete
} from '../containers/Breeder/saga';
import { watchPlanningCapacity, watchPlanningUpdate } from '../containers/Lab/saga';
import { watchLabOverview, watchLabSlotEdit } from '../containers/LabOverview/saga';
import {
  watchGetApprovalList,
  watchGetPlanPeriods,
  watchSlotApproval,
  watchSlotDenial,
  watchUpdateSlotPeriod
} from '../containers/LabApproval/saga';

import { noInternet, notificationSuccess, notificationMsg } from './notificationSagas';
// notificationGeneric

import {
  phenomeLogin,
  getResearchGroups,
  getFolders,
  importPhenome,
  getBGAvailableProjects,
  sendToThreeGBCockpit
} from '../containers/Home/saga/phenome';

import { watchFetchSlot } from '../containers/BreederOverview/saga';

/** **********************************************
 * **********************************************
 * ASSIGN
 */
import {
  watchFetchFileList,
  watchFetchTestType,
  watchFetchMaterialType,
  watchFetchMaterialState,
  watchFetchContainerType,
  watchFetchAssignData,
  watchFetchAssignFilterData,
  watchFetchAssignClearData,
  watchFetchBreeding,
  watchFetchImportSource,
  watchpostSaveNrOfSamples,
  watchDeletePost
} from '../containers/Home/saga';

import {
  watchGetDetermination,
  watchGetTrait,
  watchGetRelation,
  watchGetCrop,
  watchPostRelation
} from '../containers/Trait/sagaTrait';
import {
  watchGetResult,
  watchPostResult,
  watchGetTraitValues,
  watchGetCheckValidation
} from '../containers/TraitResult/saga';

import {
  watchMailConfigFetch,
  watchMailConfigAdd,
  watchMailConfigDelete
} from '../containers/Mail/mailSaga';

import { watchGetPlatPlan } from '../containers/PlatPlan/saga';

// UPLOAD FILE
function uploadFileApi(action) {
  const formData = new FormData();
  formData.append('file', action.file);
  formData.append('pageNumber', 1);
  formData.append('pageSize', action.pageSize);
  formData.append('testTypeID', action.testTypeID);
  formData.append('plannedDate', action.date);
  formData.append('expectedDate', action.expected);
  formData.append('materialTypeID', action.materialTypeID);
  formData.append('materialStateID', action.materialStateID);
  formData.append('containerTypeID', action.containerTypeID);
  formData.append('isolated', action.isolated);
  formData.append('source', action.source);

  if (action.source === 'External') {
    formData.append('cropCode', action.cropCode);
    formData.append('brStationCode', action.brStationCode);
  }

  /**
   * Source :: upload api is differetn
   * Breezys / External
   */
  const url =
    action.source === 'Breezys' ? urlConfig.postFile : urlConfig.postExternalFile;
  return axios({
    method: 'post',
    url,
    withCredentials: true,
    headers: {
      'content-type': 'multipart/form-data',
      enzauth: sessionStorage.token
    },
    data: formData
  });
}
function* uploadFile(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });

    // console.log(action);

    const result = yield call(uploadFileApi, action);
    const { data } = result;
    // console.log(data);

    if (data.success) {
      // clearing data, col and marker
      yield put({ type: 'RESET_ASSIGN' });

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
      // changeing page to one
      yield put({
        type: 'PAGE_RECORD',
        pageNumber: 1
      });
      // REFETCH FILE LIST

      const { breedingStationCode, cropCode } = data.file;

      // selction of breeding station
      yield put({
        type: 'BREEDING_STATION_SELECTED',
        selected: breedingStationCode
      });
      // selection of crop
      yield put({
        type: 'ADD_SELECTED_CROP',
        crop: cropCode
      });

      yield put({
        type: 'FILELIST_FETCH',
        breeding: breedingStationCode,
        crop: cropCode
      });
      yield put({ type: 'FILTER_CLEAR' });
      yield put({ type: 'FILTER_PLATE_CLEAR' });

      // selecting in the list
      const tobj = {
        testTypeID: data.file.testTypeID,
        cropCode: data.file.cropCode,
        fileID: data.file.fileID,
        fileTitle: data.file.fileTitle,
        testID: data.file.testID,
        importDateTime: data.file.importDateTime,
        plannedDate: data.file.plannedDate,
        userID: data.file.userID,
        remark: data.file.remark || '',
        remarkRequired: data.file.remarkRequired,
        statusCode: data.file.statusCode,
        slotID: null
      };
      yield put({
        type: 'FILELIST_ADD_NEW',
        file: tobj
      });
      // marker fetch :: works good
      if (action.determinationRequired) {
        yield put({
          type: 'FETCH_MARKERLIST',
          testID: data.file.testID,
          cropCode: data.file.cropCode,
          testTypeID: action.testTypeID,
          source: action.source
        });
      }
      // setting rootTestID
      // console.log(data);
      yield put({
        type: 'ROOT_SET_ALL',
        testID: data.file.testID,
        testTypeID: action.testTypeID,
        remark: data.file.remark || '',
        statusCode: data.file.statusCode,
        remarkRequired: data.file.remarkRequired,
        slotID: null
      });
      // selection in Assignm
      /* yield put({
          type: "TESTTYPE_SELECTED",
          id: action.testTypeID
      }) */
      yield put({
        type: 'FETCH_TESTLOOKUP',
        breedingStationCode,
        cropCode
      });
      // setting Filling page to 1 if new file selected
      // home
      yield put({
        type: 'PAGE_RECORD',
        pageNumber: 1
      });
      // plate
      yield put({
        type: 'PAGE_PLATE_RECORD',
        pageNumber: 1
      });
      // update test file attributes
      yield put({ type: 'SELECT_MATERIAL_TYPE', id: action.materialTypeID });
      yield put({ type: 'SELECT_MATERIAL_STATE', id: action.materialStateID });
      yield put({ type: 'SELECT_CONTAINER_TYPE', id: action.containerTypeID });
      yield put({
        type: 'CHANGE_ISOLATION_STATUS',
        isolationStatus: action.isolated
      });
      yield put({ type: 'TESTTYPE_SELECTED', id: action.testTypeID });
      yield put({ type: 'ROOT_TESTTYPEID', testTypeID: action.testTypeID });
      yield put({ type: 'CHANGE_PLANNED_DATE', plannedDate: action.date });
    } else {
      // yield put({ type: 'LOADER_HIDE' });
      const obj = {};
      obj.message = data.errors;
      yield put(notificationMsg(obj));
    }
    // yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
    // yield put({ type: 'LOADER_HIDE' });
  }
}
function* watchUploadFile() {
  yield takeEvery('UPLOAD_ACTION', uploadFile);
}

/**
 * NOT user check and remove
 * watchExternalMarker
 * externalMarker
 * externalMarkerApi
 * @param {} action
 */
function externalMakerApi(action) {
  console.log(action);
  return true;
}
function* externalMaker(action) {
  try {
    const result = yield call(externalMakerApi, action);
    console.log(result);
  } catch (e) {
    console.log(e);
  }
}
export function* watchExternalMarker() {
  yield takeEvery('EXTERNAL_MARKERLIST', externalMaker);
}

// FETCH MARKER LIST
function fetchMarkerListApi(directfromStateSource, action) {
  const checkSource = directfromStateSource || action.source;
  // console.log(action.source, '00000');
  if (checkSource === 'External') {
    return axios({
      method: 'get',
      url: urlConfig.getExternalDeterminations,
      headers: {
        enzauth: sessionStorage.token
      },
      withCredentials: true,
      params: {
        cropCode: action.cropCode,
        testTypeID: action.testTypeID
      }
    });
  }
  return axios({
    method: 'get',
    url: urlConfig.getMarkers,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    params: {
      cropCode: action.cropCode,
      testTypeID: action.testTypeID,
      testID: action.testID
    }
  });
}
function* fetchMarkerList(action) {
  // console.log('fetchMarkerList');
  /**
   * Need to get source from state as in file edit fetaure
   * source in not passed and it making difficult to select
   * which url/api to use
   */
  const getSource = state => state.assignMarker.file.selected.source;
  const directfromStateSource = yield select(getSource);
  // console.log(tokenString);
  try {
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(fetchMarkerListApi, directfromStateSource, action);
    // yield put({ type: 'LOADER_HIDE' });
    const markers = result.data;
    yield put({
      type: 'MARKER_BULK_ADD',
      data: markers.map(d => ({ ...d, selected: false }))
    });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    console.log(e);
  }
}
function* watchFetchMarkerList() {
  yield takeLatest('FETCH_MARKERLIST', fetchMarkerList);
}

// NEW PAGE
function* fetchNewPageData(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(fetchAssignFilterDataApi, action);
    const { data } = result;
    // yield put({ type: 'LOADER_HIDE' });
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
        pageNumber: action.pageNumber
      });
    }
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    console.log(e);
  }
}
function* watchFetchNewPageData() {
  yield takeEvery('NEW_PAGE', fetchNewPageData);
}
/** **********************************************
 * **********************************************
 * FILLING
 */
// TESTLOOKUP
function fetchTestLookupApi(breedingStationCode, cropCode) {
  return axios({
    method: 'get',
    url: urlConfig.getTestsLookup,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      breedingStationCode,
      cropCode
    }
  });
}
function* fetchTestLookup(action) {
  // yield put({ type: 'LOADER_SHOW' });
  // yield call(delay, 1000);
  // yield put({ type: 'LOADER_HIDE' });
  try {
    // yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    const { breedingStationCode, cropCode } = action;
    const result = yield call(
      fetchTestLookupApi,
      breedingStationCode,
      cropCode
    );

    /**
     * if test statusCode change to 300 we need to refetch grid data
     */
    // getting testID from store
    const testID = yield select(status => status.rootTestID.testID);
    let requestPlateSuccess = false; // flage to refetch grid
    // checking the change in test list
    result.data.map(r => {
      if (testID === r.testID && r.statusCode === 300) {
        requestPlateSuccess = true;
      }
      return null;
    });
    if (requestPlateSuccess) {
      const { filter, total } = yield select(status => status.plateFilling);
      const { pageNumber, pageSize } = total;
      // console.log(testID, filter, pageNumber, pageSize);
      yield put({
        type: 'PLATEDATA_FETCH',
        testID,
        pageNumber,
        pageSize,
        filter
      });
    }

    yield put({
      type: 'TESTSLOOKUP_ADD',
      data: result.data
    });
    // yield put({ type: 'LOADER_HIDE' });
    const rootTest = yield select(state => state.rootTestID);
    if (rootTest.testID !== null) {
      const v = result.data.filter(f => f.testID === rootTest.testID)[0];
      // console.log(v);
      if (v) {
        yield put({
          type: 'ROOT_SET_ALL',
          testID: v.testID,
          testTypeID: v.testTypeID,
          statusCode: v.statusCode,
          statusName: v.statusName,
          remark: v.remark,
          remarkRequired: v.remarkRequired,
          slotID: v.slotID,
          platePlanName: v.platePlanName,
          source: v.source,
          importLevel: v.importLevel,
        });
      }
      // console.log('v', v);
      yield put({
        type: 'TESTSLOOKUP_SELECTED',
        ...v
      });
      // yield put({ type: 'LOADER_RESET' });
    }
    // yield put({ type: 'LOADER_HIDE' });

  } catch (e) {
    yield put(noInternet);
  }
}
function* watchFetchTestLookup() {
  yield takeLatest('FETCH_TESTLOOKUP', fetchTestLookup);
}

// PLANT
function fetchPlantApi(action) {
  return axios({
    method: 'get',
    url: urlConfig.getPlant,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      testID: action.testID,
      query: action.value
    }
  });
}
function* fetchPlant(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    yield call(token);
    const result = yield call(fetchPlantApi, action);
    const { data } = result;
    // yield put({ type: 'LOADER_HIDE' });
    yield put({
      type: 'PLANT_BULK_ADD',
      data
    });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put(noInternet);
  }
}
function* watchFetchPlant() {
  yield takeLatest('FETCH_PLANT', fetchPlant);
}

// PLATE AFTER FILTER
function* fetchPlateFilterData(action) {
  try {
    // console.log(action);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(fetchPlateDataApi, action);
    const { data } = result;
    // yield put({ type: 'LOADER_HIDE' });
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
      type: 'PAGE_PLATE_RECORD',
      pageNumber: action.pageNumber
    });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    yield put(noInternet);
  }
}
function* watchFetchPlateFilterData() {
  yield takeEvery('FETCH_PLATE_FILTER_DATA', fetchPlateFilterData);
}
// PLATE FILTER CLEAR
function* actionPlateFilterClear(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(fetchPlateDataApi, action);
    const { data } = result;
    // yield put({ type: 'LOADER_HIDE' });
    yield put({
      type: 'DATA_FILLING_BULK_ADD',
      data: data.data.data
    });
    yield put({
      type: 'TOTAL_PLATE_RECORD',
      total: data.total
    });
    yield put({
      type: 'PAGE_PLATE_RECORD',
      pageNumber: action.pageNumber
    });
    yield put({
      type: 'FILTER_PLATE_CLEAR'
    });
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
  }
}
function* watchActionPlateFilterClear() {
  yield takeEvery('FETCH_CLEAR_PLATE_FILTER_DATA', actionPlateFilterClear);
}
// ASSIGN FIX POSITION
function assignFixPositionApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.postAssignFixedPosition,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      wellPosition: action.wellPosition,
      materialID: action.materialID
    }
  });
}
function* actionAssignFixPosition(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(assignFixPositionApi, action);
    const { data } = result;

    // yield put({ type: 'LOADER_HIDE' });
    if (data) {
      yield put(notificationSuccess('Fixed position assign success.'));
      yield put({
        type: 'WELL_REMOVE',
        position: action.wellPosition
      });
      yield put({
        type: 'TESTSLOOKUP_SET_FIXEDPOSITION_CHANGE',
        testID: action.testID
      });
      // TODO :: need testign
      const pageSize = yield select(state => state.plateFilling.total.pageSize);
      const result2 = yield call(fetchPlateDataApi, {
        testID: action.testID,
        filter: [],
        pageNumber: 1,
        pageSize: pageSize || 200
      });
      const data2 = result2.data;
      yield put({
        type: 'DATA_FILLING_BULK_ADD',
        data: data2.data.data
      });
      yield put({ type: 'SIZE_PLATE_RECORD', pageSize: pageSize || 200 });
      yield put({
        type: 'PAGE_PLATE_RECORD',
        pageNumber: 1
      });
    } else {
      yield put(noInternet);
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
function* watchActionAssignFixPosition() {
  yield takeEvery('ASSIGN_FIX_POSITION', actionAssignFixPosition);
}
// NEW PAGE
function* fetchNewPlatePageData(action) {
  try {
    // yield put({type: 'LOADER_SHOW'});
    const result = yield call(fetchPlateDataApi, action);
    const { data } = result.data;
    yield put({
      type: 'DATA_FILLING_BULK_ADD',
      data: data.data
    });
    yield put({
      type: 'COLUMN_FILLING_BULK_ADD',
      data: data.columns
    });
    yield put({
      type: 'TOTAL_PLATE_RECORD',
      total: result.data.total
    });
    yield put({
      type: 'PAGE_PLATE_RECORD',
      pageNumber: action.pageNumber
    });

    // yield put({type: 'LOADER_HIDE'});
  } catch (e) {
    console.log(e);
  }
}
function* watchFetchNewPlatePageData() {
  yield takeEvery('NEW_PLATE_PAGE', fetchNewPlatePageData);
}

// GET PUNCH LIST
function fetchPunchListApi(action) {
  return axios({
    method: 'get',
    url: urlConfig.getPunchList,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    params: {
      testID: action.testID
    }
  });
}
function* fetchPunchList(action) {
  try {
    // yield put({ type: 'LOADER_SHOW' });
    // ADD_PUNCHLIST
    const result = yield call(fetchPunchListApi, action);
    yield put({
      type: 'ADD_PUNCHLIST',
      data: result.data
    });
    // yield put({ type: 'LOADER_HIDE' });
  } catch (e) {
    // console.log('You are getting error ::');
    console.log(e);
    // yield put({ type: 'LOADER_HIDE' });
  }
}
function* watchFetchPunchList() {
  yield takeLatest('FETCH_PUNCHLIST', fetchPunchList);
}
// POST PLATE LABEL
function requestPlateLabelApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.postPlateLabel,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    data: {
      testID: action.testID
    }
  });
}
function* requestPlateLabel(action) {
  try {
    const result = yield call(requestPlateLabelApi, action);
    const { data } = result;
    // result acc :: success, error, printerName
    if (data.success) {
      // TODO :: check this message after service circle works.
      yield put(notificationSuccess('Plate label queued for printing.'));
      // data.printerName
    } else {
      const obj = {};
      obj.message = data.error;
      yield put(notificationMsg(obj));
    }
  } catch (e) {
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
function* watchRequestPlateLabel() {
  yield takeLatest('PLATE_LABEL_REQUEST', requestPlateLabel);
}
// REMARK
function postRemarkApi(action) {
  return axios({
    method: 'put',
    url: urlConfig.putTestSaveRemark,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID: action.testID,
      remark: action.remark
    }
  });
}
function* postRemark(action) {
  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW'});
    const result = yield call(postRemarkApi, action);
    if (result.data) {
      yield put({
        type: 'ROOT_REMARK',
        remark: action.remark
      });
      yield put({
        type: 'FILELIST_SET_REMARK',
        testID: action.testID,
        remark: action.remark
      });
      yield put({
        type: 'TESTSLOOKUP_SET_REMARK',
        testID: action.testID,
        remark: action.remark
      });
      yield put(notificationSuccess('Remark successfully saved.'));
    }
  } catch (e) {
    yield put(noInternet);
  }
  // yield put({ type: 'LOADER_HIDE' });
}
function* watchPostRemark() {
  yield takeLatest('ROOT_SET_REMARK', postRemark);
}
// COMPLETE REQUEST && REMARK
function confirmRequestApi(action) {
  return axios({
    method: 'put',
    url: urlConfig.putCompleteTestRequest,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    data: {
      testId: action.testId
    }
  });
}
function* confirmRequest(action) {
  try {
    // yield put({ type: 'LOADER_SHOW'});
    const result = yield call(confirmRequestApi, action);
    if (action.testId === result.data.testID) {
      yield put({
        type: 'ROOT_STATUS',
        statusCode: result.data.statusCode,
        testID: result.data.testID
      });
      yield put(notificationSuccess('Confirm request successfully.'));
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
    } else {
      yield put(noInternet);
    }
  }
  // yield put({ type: 'LOADER_HIDE'});
}
function* watchConfirmRequest() {
  yield takeEvery('TESTSLOOKUP_CONFIRM_REQUEST', confirmRequest);
}

// Plate Reserve Call
function toLIMSApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.postPlateInLims,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    data: {
      testID: action.testID
    }
  });
}
function* toLIMS(action) {
  // yield put({ type: 'LOADER_SHOW'});
  try {
    const result = yield call(toLIMSApi, action);
    yield put({
      type: 'ROOT_STATUS',
      statusCode: result.data.statusCode,
      testID: result.data.testID
    });
    yield put(notificationSuccess('Request sent to LIMS successfully.'));
    // yield put({type: 'LOADER_HIDE'});
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE'});
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
function* watchToLIMS() {
  yield takeEvery('REQUEST_TO_LIMS', toLIMS);
}

/** **********************************************
 *  *********************************************
 * FINAL CALL
 */
export default function* rootSaga() {
  // console.log('rootSaga');
  // yield call(token);
  yield all([
    watchFetchGetExternalTests(),
    watchExportTest(),

    watchGetSlotList(),
    watchPostLinkSlotTest(),

    watchFetchFileList(),
    watchUploadFile(),
    watchFetchMaterialType(),
    watchFetchMaterialState(),
    watchFetchContainerType(),
    watchFetchAssignData(),
    watchFetchTestType(),
    watchFetchMarkerList(),
    watchAssignMarker(),
    watchAddToThreeGB(),
    watchFetchThreeGB(),
    watchSave3GBmarker(),
    watchFetchAssignFilterData(),
    watchFetchAssignClearData(),
    watchFetchBreeding(),
    watchFetchImportSource(),
    watchpostSaveNrOfSamples(),
    watchDeletePost(),

    watchFetchNewPageData(),
    watchFetchTestLookup(),
    watchFetchWell(),
    watchFetchPlant(),
    watchFetchPlateData(),
    watchFetchNewPlatePageData(),
    watchActionAssignFixPosition(),
    watchActionSaveDB(),
    watchFetchPlateFilterData(),
    watchActionPlateFilterClear(),
    watchFetchPunchList(),
    watchRequestPlateLabel(),
    watchReservePlate(),
    watchUndoFixedPosition(), // undoFix
    watchToLIMS(),
    watchPostRemark(),
    watchConfirmRequest(),
    watchDeleteRow(),
    watchUndoDead(),
    watchDeleteReplicate(),
    watchFetchWellType(),
    watchFetchStatusList(),
    watchFetchMaterials(),
    watchFetchMaterialsWithDeterminationsForExternalTest(),
    watchUpdateTestAttributesDispatch(),
    watchFetchFilteredMaterials(),
    watchCreateReplicaDispatch(),
    watchDeleteDeadMaterialsDispatch(),
    watchSaveMaterialMarker(),
    watchExternalMarker(),

    watchBreeder(),
    watchCropChange(),
    watchBreederReserve(),
    watchPeriod(),
    watchPlantsTests(),
    watchSlotDelete(),

    watchPlanningCapacity(),
    watchPlanningUpdate(),
    watchLabOverview(),
    watchLabSlotEdit(),

    watchGetApprovalList(),
    watchGetPlanPeriods(),
    watchSlotApproval(),
    watchSlotDenial(),
    watchUpdateSlotPeriod(),
    watchToken(),
    yield takeLatest('PHENOME_LOGIN', phenomeLogin),
    yield takeLatest('GET_RESEARCH_GROUPS', getResearchGroups),
    yield takeLatest('GET_FOLDERS', getFolders),
    yield takeLatest('IMPORT_PHENOME', importPhenome),
    yield takeLatest('THREEGB_PROJECTLIST_FETCH', getBGAvailableProjects),
    yield takeLatest('THREEGB_SEND_COCKPIT', sendToThreeGBCockpit),

    watchGetDetermination(),
    watchGetTrait(),
    watchGetRelation(),
    watchGetCrop(),
    watchPostRelation(),

    watchGetResult(),
    watchPostResult(),
    watchGetTraitValues(),
    watchGetCheckValidation(),

    watchFetchSlot(),

    watchMailConfigFetch(),
    watchMailConfigAdd(),
    watchMailConfigDelete(),

    watchGetPlatPlan()
  ]);
}
