import { call, takeLatest, put } from 'redux-saga/effects';
import { getSlotListApi, postLinkSlotTestApi } from '../api/index';
import { slotAdd } from '../../../containers/Home/actions/index';
import { noInternet, notificationGeneric, notificationMsg, notificationSuccess } from '../../../saga/notificationSagas';
import { token } from '../../../saga/tokenSagas';

function* getSlotList({ testID, slotID }) {

  if (testID === null) {
    return null;
  }

  try {
    yield call(token);
    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(getSlotListApi, testID);
    // console.log(result.data);
    // slotAdd();
    yield put(slotAdd(result.data, slotID));

    // yield put({ type: 'LOADER_HIDE' });
  } catch (err) {
    // yield put({ type: 'LOADER_HIDE' });
    console.log(err);
  }
}
export function* watchGetSlotList() {
  yield takeLatest('FETCH_SLOT', getSlotList);
}

function* postLinkSlotTest(action) {
  try {
    yield call(token);

    // yield put({ type: 'LOADER_SHOW' });
    const result = yield call(postLinkSlotTestApi, action);

    const { data } = result;
    // console.log(data);
    /**
     * TODO :: fetch data again
     * both Assign marker and Plate Filling page
     */
    yield put({
      type: 'ROOT_SLOTID',
      slotID: parseInt(action.slotID),
      testID: data.testID
    });
    yield put({
      type: 'ROOT_STATUS',
      statusCode: data.statusCode,
      testID: data.testID
    });

    // yield put({
    //   type: 'ROOT_SLOTID',
    //   slotID: action.slotID
    // });

    // yield put({ type: 'LOADER_HIDE' });
    // console.log(action);
    const msg =
      action.slotID === ''
        ? 'SLot was successfull Unassigned.'
        : 'Slot was successfully assigned.';
    yield put(notificationSuccess(msg));
  } catch (e) {
    // yield put({ type: 'LOADER_HIDE' });
    // console.log(e);
    yield put(notificationMsg(e.response.data));
  }
}
export function* watchPostLinkSlotTest() {
  yield takeLatest('UPDATE_SLOT_TEST_LINK', postLinkSlotTest);
}
