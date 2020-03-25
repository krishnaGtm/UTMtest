/**
 * Created by sushanta on 3/14/18.
 */
import axios from 'axios';
import urlConfig from '../../../urlConfig';

export const getApprovalListApi = (periodID, tokenKey) => {
  // console.log('app list ', periodID, tokenKey)
  return axios({
    method: 'get',
    url: urlConfig.getApprovalListForLab,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      periodID
    }
  });
};

export const getPlanPeriodsApi = tokenKey =>
  axios({
    method: 'get',
    url: urlConfig.getPlanPeriods,
    headers: {
      enzauth: tokenKey
    },
    withCredentials: true
  });

export const approveSlotApi = (slotID, tokenKey) => {
  // slotID = null;
  // console.log('--- api ', slotID, tokenKey);
  return axios({
    method: 'post',
    url: urlConfig.approveSlot,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      slotID: slotID
    }
  });
};

export const denySlotApi = (slotID, tokenKey) =>
  axios({
    method: 'post',
    url: urlConfig.denySlot,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    params: {
      slotID
    }
  });

export const updateSlotPeriodApi = (
  slotID,
  plannedDate,
  expectedDate,
  tokenKey
) =>
  axios({
    method: 'put',
    url: urlConfig.updateSlotPeriod,
    withCredentials: true,
    headers: {
      enzauth: tokenKey
    },
    data: {
      slotID,
      plannedDate,
      expectedDate
    }
  });
