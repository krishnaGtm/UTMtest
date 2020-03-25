import axios from 'axios';
import urlConfig from '../../urlConfig';

export function fetchGetExternalTestsApi({ brStationCode, cropCode, showAll }) {
  // console.log(brStationCode, cropCode, showAll);
  // return true;
  return axios({
    method: 'get',
    url: urlConfig.getExternalTests,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    params: {
      brStationCode,
      cropCode,
      showAll
    }
  });
}

export function fetchGetExportApi(action) {
  const { testID, mark } = action;
  return axios({
    method: 'get',
    url: urlConfig.getExport,
    headers: {
      enzauth: sessionStorage.token,
      Accept: 'application/vnd.ms-excel'
    },
    withCredentials: true,
    responseType: 'arraybuffer',
    params: {
      testID,
      mark
    }
  });
}
