import axios from 'axios';
import urlConfig from '../../urlConfig';

export const getTraitRelationApi = (pageNumber, pageSize, filter) =>
  axios({
    method: 'post',
    url: urlConfig.getTraitResults,
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

export const postTraitRelationApi = data =>
  axios({
    method: 'post',
    url: urlConfig.postTraitResults,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });

export const getTraitValuesApi = cropTraitID =>
  axios({
    method: 'get',
    url: urlConfig.getTraitValues,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      cropTraitID
    }
  });

export const getCheckValidationApi = source =>
  axios({
    method: 'get',
    url: urlConfig.checkValidation,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      source
    }
  });
