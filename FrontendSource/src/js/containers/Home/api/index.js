import axios from 'axios';
import urlConfig from '../../../urlConfig';

export function fetchFileListApi(breedingStationCode, cropCode) {
  return axios({
    method: 'get',
    url: urlConfig.getFileList,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true,
    params: {
      breedingStationCode,
      cropCode
    }
  });
}

export function fetchTestTypeApi() {
  return axios({
    method: 'get',
    url: urlConfig.getTestType,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}

export function fetchMaterialTypeApi() {
  return axios({
    method: 'get',
    url: urlConfig.getmaterialType,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}

export function fetchMaterialStateApi() {
  return axios({
    method: 'get',
    url: urlConfig.getmaterialState,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}

export function fetchContainerTypeApi() {
  return axios({
    method: 'get',
    url: urlConfig.getContainerTypes,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}

export function fetchAssignDataApi(action) {
  const markerURL =
    action.source === 'External'
      ? urlConfig.getExternalDeterminations
      : urlConfig.getMarkers;
  return axios.all([
    axios({
      method: 'post',
      url: urlConfig.getFileData,
      withCredentials: true,
      headers: {
        enzauth: sessionStorage.token
      },
      data: {
        testTypeID: action.testTypeID,
        testID: action.testID,
        pageNumber: action.pageNumber,
        pageSize: action.pageSize,
        filter: action.filter
      }
    }),
    axios({
      method: 'get',
      url: markerURL,
      withCredentials: true,
      headers: {
        enzauth: sessionStorage.token
      },
      params: {
        cropCode: action.cropCode,
        testTypeID: action.testTypeID,
        testID: action.testID
      }
    })
  ]);
}

export function fetchAssignFilterDataApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.getFileData,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testTypeID: action.testTypeID,
      testID: action.testID,
      pageNumber: action.pageNumber,
      pageSize: action.pageSize,
      filter: action.filter
    }
  });
}

export function fetchBreedingApi() {
  return axios({
    method: 'get',
    url: urlConfig.getBreedingNew,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    }
  });
}

export function fetchImportSourceApi() {
  return axios({
    method: 'get',
    url: urlConfig.getImportSource,
    headers: {
      enzauth: sessionStorage.token
    },
    withCredentials: true
  });
}

export function postSaveNrOfSamplesApi(action) {
  return axios({
    method: 'post',
    url: urlConfig.postSaveNrOfSamples,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: action
  });
  // return true;
}

/**
 * DELETE TEST
 * This api will change test status and don't show in list
 */
export function postDeleteTestApi(testID) {
  // return true;
  return axios({
    method: 'post',
    url: urlConfig.postDeleteTest,
    withCredentials: true,
    headers: {
      enzauth: sessionStorage.token
    },
    data: {
      testID
    }
  });
}
