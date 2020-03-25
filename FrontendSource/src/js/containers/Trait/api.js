import axios from 'axios';
import urlConfig from '../../urlConfig';

export const getCropApi = () =>
  axios({
    method: 'get',
    url: urlConfig.getCrop,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    }
  });

export const getRelationTraitApi = (traitName, cropCode, source) =>
  axios({
    method: 'get',
    url: urlConfig.getRelationTrait,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      traitName,
      cropCode,
      source
    }
  });

export const getRelationDeterminationApi = (determinationName, cropCode) =>
  axios({
    method: 'get',
    url: urlConfig.getRelationDetermination,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: {
      determinationName,
      cropCode
    }
  });

export const getRelationApi = (pageNumber, pageSize, filter) =>
  axios({
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

export const postRelationApi = (data) =>
  axios({
    method: 'post',
    url: urlConfig.postRelation,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data
  });
