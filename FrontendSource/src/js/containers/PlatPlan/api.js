import axios from 'axios';
import urlConfig from '../../urlConfig';

export const getPlatPlanApi = (pageNumber, pageSize, filter) =>
  axios({
    method: 'post',
    url: urlConfig.getPlatPlan,
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