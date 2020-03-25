import axios from 'axios';
import urlConfig from '../../../urlConfig';

export const getSlotListApi = testID => {
  return axios({
    method: 'get',
    url: urlConfig.getSlot,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    params: { testID }
  });
};

export const postLinkSlotTestApi = ({testID, slotID}) => {
  // console.log(testID, slotID);
  return axios({
    method: 'post',
    url: urlConfig.getLinkSlotTest,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID,
      slotID
    }
  });
};
