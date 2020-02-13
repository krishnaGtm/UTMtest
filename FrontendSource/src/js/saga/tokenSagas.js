import { call, takeLatest, put, select } from 'redux-saga/effects'; // select
import axios from 'axios/index';
// import jwtDecode from 'jwt-decode';
// import moment from 'moment';
import urlConfig from '../urlConfig';

export function tokenApi() {
  return axios({
    method: 'get',
    url: urlConfig.token,
    withCredentials: true
  });
}

function actionToken(exp, role, tok, crops) {
  // console.log(crops);
  let newCrop = [];
  if (Array.isArray(crops)) {
    newCrop = crops.slice();
  } else {
    newCrop = [crops];
  }
  // console.log(crops);
  return {
    type: 'ADD_ROLE',
    exp,
    role,
    token: tok,
    crops: newCrop
  };
}

function computeTimeAdd(t) {
  const adding = t / 60000;
  if (adding < 1) {
    return 1;
  }
  return adding;
}
export function* token() {
  try {
    let getToken = state => state.user.token;
    const tokenString = yield select(getToken);

    // console.log('tokenString', tokenString);
    if (tokenString === null) {
      // console.log('tokenString null : ', tokenString);

      const result = yield call(tokenApi);
      const { data } = result;
      const { expiresIn, issuedOn } = data;
      const checkTime = new Date(expiresIn) - new Date(issuedOn);
      // console.log('ct', checkTime);

      const d = new Date();
      d.setMinutes(d.getMinutes() + computeTimeAdd(checkTime));

      sessionStorage.setItem('exp', d.getTime());
      sessionStorage.setItem('token', result.data.token);

      const ab = result.data.token.split('.')[1];
      const rr = JSON.parse(atob(ab));

      yield put(
        actionToken(
          d.getTime(),
          rr.role,
          result.data.token,
          rr['enzauth.crops']
        )
      );
      return result.data.token;
    }

    // console.log('tokenString not null', tokenString);
    const getExp = sessionStorage.getItem('exp');
    getToken = sessionStorage.getItem('token');

    const CD = new Date();
    const diff = getExp - CD.getTime();

    if (diff < 1) {
      // console.log('diff : ', diff);
      // console.log(getToken === tokenString);

      const result = yield call(tokenApi);
      const { data } = result;
      const { expiresIn, issuedOn } = data;
      const checkTime = new Date(expiresIn) - new Date(issuedOn);
      // console.log('ct', checkTime);

      const d = new Date();
      d.setMinutes(d.getMinutes() + computeTimeAdd(checkTime));

      sessionStorage.setItem('exp', d.getTime());
      sessionStorage.setItem('token', result.data.token);

      const ab = result.data.token.split('.')[1];
      const rr = JSON.parse(atob(ab));
      yield put(
        actionToken(
          d.getTime(),
          rr.role,
          result.data.token,
          rr['enzauth.crops']
        )
      );
      return result.data.token;
    }

    // console.log(22);
    const ab = getToken.split('.')[1];
    const rr = JSON.parse(atob(ab));
    yield put(actionToken(getExp, rr.role, getToken, rr['enzauth.crops']));
    return getToken;
  } catch (e) {
    // console.log(e.response);
    console.log('Unable to fetch token.');
  }
}

export function* watchToken() {
  // yield takeLatest('*', token);
  yield takeLatest('FETCH_TOKEN', token);
}
