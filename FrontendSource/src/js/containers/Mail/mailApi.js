import axios from 'axios';
import urlConfig from '../../urlConfig';

// FETCH
export function mailConfig_fetchApi(pageNumber, pageSize, tokenKey) {
  // return true;
  return axios({
    method: 'get',
    url: urlConfig.getEmailConfig,
    headers: {
      enzauth: tokenKey
    },
    withCredentials: true,
    params: {
      pageNumber,
      pageSize,
      configGroup: '',
      cropCode: ''
    }
  });
}

// ADD
export function mailConfig_appendApi(configID, cropCode, configGroup, recipients, tokenKey) {
  return axios({
    method: 'post',
    url: urlConfig.postEmailConfig,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    data: {
      configID,
      cropCode,
      configGroup,
      recipients
    }
  });
}

// EDIT
export function mailConfig_editApi(pageNumber, pageSize, filter) {
  return axios({
    method: 'post',
    url: urlConfig.getRelation,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      pageNumber,
      pageSize,
      filter
    }
  });
}

// DELETE
export function mailConfig_deleteApi(configID, tokenKey) {
  return axios({
    method: 'delete',
    url: urlConfig.deletEmailConfig,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    data: {
      configID
    }
  });
}