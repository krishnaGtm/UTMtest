/**
 * Created by sushanta on 4/12/18.
 */
import axios from 'axios';
import shortid from 'shortid';
import urlConfig from '../../../urlConfig';

export function phenomeLoginApi({ user, pwd }) {
  return axios({
    method: 'post',
    url: urlConfig.phenomeLogin,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      userName: user,
      password: pwd
    },
    withCredentials: true
  });
}
export function phenomeLoginSSOApi({ token }) {
  return axios({
    method: 'post',
    url: urlConfig.phenomeSSOLogin,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      token
    },
    withCredentials: true
  });
}
export function getResearchGroupsApi() {
  return axios({
    method: 'get',
    url: urlConfig.getResearchGroups,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}
export function getFoldersApi(id) {
  return axios({
    method: 'get',
    url: urlConfig.getFolders,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    params: {
      id
    }
  });
}
export function importPhenomeApi(data) {
  // console.log(data);
  return axios({
    method: 'post',
    url: urlConfig.importPhenome,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    data: {
      ...data,
      pageNumber: 1,
      gridID: shortid.generate().substr(1, 8),
      pageSize: 200,
      positionStart: '0'
    }
  });
}

export function getThreeGBavailableProjectsApi(
  cropCode,
  brStationCode,
  testTypeCode
) {
  return axios({
    method: 'get',
    url: urlConfig.getThreeGBavailableProjects,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    params: {
      cropCode,
      brStationCode,
      testTypeCode
    }
  });
}

export function importPhenomeThreegbApi(data) {
  // console.log(data, ' --- API ===');
  return axios({
    method: 'post',
    url: urlConfig.postThreeGBimport,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    data: {
      ...data,
      pageNumber: 1,
      gridID: shortid.generate().substr(1, 8),
      pageSize: 200,
      positionStart: '0'
    }
  });
}

export function sendToThreeGBCockPitApi(testID, filter) {
  // const data
  // url: "http://10.0.0.78:8888/Services/api/v1/threeGB/sendTo3GBCockpit?testID=123",
  return axios({
    method: 'post',
    url: urlConfig.postSendToThreeGBCockpit,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    data: {
      testID
    }
  });
}
