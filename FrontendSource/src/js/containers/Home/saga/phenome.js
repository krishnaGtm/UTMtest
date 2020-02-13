/**
 * Created by sushanta on 4/12/18.
 */
import { call, put, select } from 'redux-saga/effects';
import parse from 'xml-parser';
import { lensPath, set, concat } from 'ramda';
import {
  phenomeLoginApi,
  phenomeLoginSSOApi,
  getResearchGroupsApi,
  getFoldersApi,
  importPhenomeApi,
  getThreeGBavailableProjectsApi,
  importPhenomeThreegbApi,
  sendToThreeGBCockPitApi
} from '../api/phenome';
import {
  phenomeLoginDone,
  getResearchGroupsDone,
  getFoldersDone,
  phenomeLogout
} from '../actions/phenome';

// import { token } from '../../../saga/tokenSagas';
import { noInternet, notificationMsg, notificationSuccess } from '../../../saga/notificationSagas';

import { show, hide } from '../../../helpers/helper';


// export function* phenomeLogin({ user, pwd }) {
export function* phenomeLogin(action) {
  try {
    yield put(show('phenomeLogin'));
    // const response = yield call(phenomeLoginApi, user, pwd);
    const loginUrl = window.sso.enabled ? phenomeLoginSSOApi : phenomeLoginApi;
    const response = yield call(loginUrl, action);
    if (response.data.status) {
      yield put(phenomeLoginDone());
    } else {
      const obj = {};
      obj.message = response.data.message;
      yield put(notificationMsg(obj));
    }
    yield put(hide('phenomeLogin'));
  } catch (err) {
    yield put(hide('phenomeLogin'));
    console.log(err);
  }
}
export function* getResearchGroups() {
  try {
    // yield put(show('getResearchGroups'));
    const response = yield call(getResearchGroupsApi);
    const data = {};
    if (response.data) {
      const obj = parse(response.data);
      // console.log(obj);
      const rootItem = obj.root.children[0];
      if (rootItem.attributes.status === '0') {
        yield put(phenomeLogout());
      }
      if (rootItem.attributes.text) {
        data.name = rootItem.attributes.text;
        data.img = rootItem.attributes.im0;
        data.children = [];
        let i = 0;
        let j = 0;
        while (i < rootItem.children.length) {
          const child = rootItem.children[i];
          if (child.attributes.text) {
            data.children.push({
              name: child.attributes.text,
              img: child.attributes.im0,
              id: child.attributes.id,
              children: [],
              path: ['children', j, 'children'],
              objectType: child.children.find(item => item.attributes.name === 'ObjectType').content
            });
            j += 1;
          }
          i += 1;
        }
      }
    }
    yield put(getResearchGroupsDone(data));
    yield put(hide('getResearchGroups'));
  } catch (err) {
    yield put(hide('getResearchGroups'));
    console.log(err);
  }
}
export function* getFolders({ id, path }) {
  try {
    yield put(show('getFolders'));
    const response = yield call(getFoldersApi, id);
    const data = [];
    if (response.data) {
      const obj = parse(response.data);
      const rootItem = obj.root;
      if (rootItem.children.length > 0) {
        if (rootItem.children[0].attributes.status === '0') {
          yield put(phenomeLogout());
        }
      }
      if (rootItem.attributes.id) {
        let i = 0;
        let j = 0;
        while (i < rootItem.children.length) {
          const child = rootItem.children[i];
          if (child.attributes.text) {
            data.push({
              name: child.attributes.text,
              img: child.attributes.im0,
              id: child.attributes.id,
              children: child.attributes.child ? [] : null,
              path: concat(path, [j, 'children']),
              objectType: child.children.find(item => item.attributes.name === 'ObjectType').content,
              researchGroupID: child.children.find(item => item.attributes.name === 'rg_id').content
            });
            j += 1;
          }
          i += 1;
        }
      }
    }
    const currentTreeData = yield select(state => state.phenome.treeData);
    const newTreeData = set(lensPath(path), data, currentTreeData);
    yield put(getFoldersDone(newTreeData));
    yield put(hide('getFolders'));
  } catch (err) {
    yield put(hide('getFolders'));
    console.log(err);
  }
}
export function* importPhenome(action) {
  try {
    yield put(show('importPhenome'));
    let result = [];
    const { testTypeID } = action.data;
    if (testTypeID === 4 || testTypeID === 5) {
      result = yield call(importPhenomeThreegbApi, action.data);
    } else {
      result = yield call(importPhenomeApi, action.data);
    }
    // return null;
    // console.log(result.data);
    // console.log(result);
    // TODO :: saga.js 117 code replace
    // Start copy sage file upload
    const { data } = result;
    // console.log(action);

    if (data.success) {
      yield put({ type: 'RESET_ASSIGN' });

      // Clear confirm box
      yield put({ type: 'PHENOME_WARNING_FALSE' });

      yield put({ type: 'DATA_BULK_ADD', data: data.dataResult.data });
      yield put({ type: 'COLUMN_BULK_ADD', data: data.dataResult.columns });
      yield put({ type: 'TOTAL_RECORD', total: data.total });
      // changeing page to one
      yield put({ type: 'PAGE_RECORD', pageNumber: 1 });
      // REFETCH FILE LIST
      // console.log(data, '-- after phenome import success filelist fetch tase ---');

      const { breedingStationCode, cropCode } = data.file;

      // selction of breeding station
      yield put({ type: 'BREEDING_STATION_SELECTED', selected: breedingStationCode });
      // selection of crop
      yield put({ type: 'ADD_SELECTED_CROP', crop: cropCode });

      // expectedDate

      yield put({
        type: 'FILELIST_FETCH',
        breeding: breedingStationCode,
        crop: cropCode
      });
      yield put({ type: 'FILTER_CLEAR' });
      yield put({ type: 'FILTER_PLATE_CLEAR' });

      // todo make params correction
      // console.log(data.file, '===========');
      const tobj = {
        testTypeID: data.file.testTypeID,
        cropCode: data.file.cropCode,
        fileID: data.file.fileID,
        fileTitle: data.file.fileTitle,
        testID: data.file.testID,
        importDateTime: data.file.importDateTime,
        plannedDate: data.file.plannedDate,
        userID: data.file.userID,
        remark: data.file.remark, // init blank
        remarkRequired: data.file.remarkRequired,
        statusCode: data.file.statusCode,
        slotID: null,
        expectedDate: data.file.expectedDate,
        importLevel: action.data.importLevel
      };
      yield put({ type: 'FILELIST_ADD_NEW', file: tobj });
      // marker fetch :: works good

      if (action.data.determinationRequired) {
        yield put({
          type: 'FETCH_MARKERLIST',
          testID: data.file.testID,
          cropCode: data.file.cropCode,
          testTypeID: action.data.testTypeID
        });
      }
      // setting rootTestID
      yield put({
        type: 'ROOT_SET_ALL',
        testID: data.file.testID,
        testTypeID: data.file.testTypeID,
        remark: data.file.remark || '',
        statusCode: data.file.statusCode,
        remarkRequired: data.file.remarkRequired,
        slotID: null
      });

      yield put({ type: 'FETCH_TESTLOOKUP', breedingStationCode, cropCode });
      // setting Filling page to 1 if new file selected
      // home
      yield put({ type: 'PAGE_RECORD', pageNumber: 1 });
      // plate
      yield put({ type: 'PAGE_PLATE_RECORD', pageNumber: 1 });
      // update test file attributes
      yield put({ type: 'SELECT_MATERIAL_TYPE', id: data.file.materialTypeID });
      yield put({ type: 'SELECT_MATERIAL_STATE', id: data.file.materialstateID });
      yield put({ type: 'SELECT_CONTAINER_TYPE', id: data.file.containerTypeID });
      yield put({ type: 'CHANGE_ISOLATION_STATUS', isolationStatus: data.file.isolated });
      yield put({ type: 'CHANGE_CUMULATE_STATUS', cumulate: data.file.cumulate });
      yield put({ type: 'TESTTYPE_SELECTED', id: data.file.testTypeID });
      yield put({ type: 'ROOT_TESTTYPEID', testTypeID: data.file.testTypeID });
      yield put({ type: 'CHANGE_PLANNED_DATE', plannedDate: data.file.plannedDate });
      yield put(hide('importPhenome'));
    } else {
      const { errors, warnings } = data;
      const obj = {};
      if (warnings.length > 0) {
        /////////////
        // WARNING //
        /////////////
        // console.log('import phenome warnings');
        yield put({
          type: 'PHENOME_WARNING',
          warningMessage: warnings
        });
      }
      else {
        // ERROR
        obj.message = errors;
        yield put(notificationMsg(obj));
      }
    }

    yield put(hide('importPhenome'));
    // END copy
  } catch (e) {
      yield put(hide('importPhenome'));
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}

export function* getBGAvailableProjects(action) {
  try {
    yield put(show('getBGAvailableProjects'));
    // console.log(action);
    const result = yield call(getThreeGBavailableProjectsApi, action.crop, action.breeding, action.testTypeCode);
    // console.log(result);
    yield put({ type: 'THREEGB_DATA_BULK_ADD', data: result.data });
    yield put(hide('getBGAvailableProjects'));
  } catch (e) {
    yield put(hide('getBGAvailableProjects'));
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}

export function* sendToThreeGBCockpit(action) {
  try {
    yield put(show('sendToThreeGBCockpit'));

    const result = yield call(sendToThreeGBCockPitApi, action.testID, action.filter);
    // console.log(sendToThreeGBCockPitApi(1,2));
    // console.log(action);
    // console.log(result.data);
    if (result.data) {
      // yield put({ type: 'RESET_ASSIGN' });
      yield put({ type: 'RESETALL' });
      // filelistreducer reset
      yield put({ type: 'RESET_ALL' });
      // testslookup rest
      yield put({ type: 'TESTSLOOKUP_RESET_ALL' });

      yield put({
        type: 'REMOVE_FILE_AFTER_SENDTO_3GB',
        testID: action.testID
      });
      yield put(notificationSuccess('Successfully sent to 3GB cockpit.'));
    }

    yield put(hide('sendToThreeGBCockpit'));
  } catch (e) {
    yield put(hide('sendToThreeGBCockpit'));
    if (e.response !== undefined) {
      if (e.response.data) {
        yield put(notificationMsg(e.response.data));
      }
    } else {
      yield put(noInternet);
    }
  }
}
