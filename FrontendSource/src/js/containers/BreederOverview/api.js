import axios from 'axios';
import urlConfig from '../../urlConfig';

export const fetchSlotAPi = (cropCode, brStationCode, pageNumber, pageSize, filter) =>
  axios({
    method: 'post',
    url: urlConfig.getSlotBreedingOverview,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      cropCode,
      brStationCode,
      pageNumber,
      pageSize,
      filter
    }
  });
