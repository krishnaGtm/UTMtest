export const getResults = (pageNumber, pageSize, filter) => ({
  type: 'GET_RESULT',
  pageNumber,
  pageSize,
  filter
});

// export const getTraitValues = (cropCode, traitID) => ({
export const getTraitValues = cropTraitID => ({
  type: 'FETCH_TRAITVALUES',
  cropTraitID
});

export const postData = data => ({
  type: 'POST_RESULT',
  data
});

export const traitValuesReset = () => ({
  type: 'TRAITVALUE_RESET'
});

export const resetFilter = () => ({
  type: 'FILTER_TRAITRESULT_CLEAR'
});

export const getCheckValidation = source => ({
  type: 'getCheckValidation',
  source
});
export const resetCheckValidation = () => ({
  type: 'CHECKVALIDATION_RESET'
});

// notification
export const showNotification = (message, messageType, code) => ({
  type: 'NOTIFICATION_SHOW',
  status: true,
  message,
  messageType,
  notificationType: 0,
  code: code || ''
});

// saga
export const storeResult = data => ({
  type: 'RESULT_BULK',
  data
});

export const storeAppend = data => ({
  type: 'RESULT_ADD',
  data
});

export const storeTraitValues = data => ({
  type: 'TRAITVALUE_BULK',
  data
});

export const storeCheckValidtion = data => ({
  type: 'CHECKVALIDATION_BULK',
  data
});

export const storeTotal = total => ({
  type: 'TRAITRESULT_RECORDS',
  total
});

export const storePage = pageNumber => ({
  type: 'TRAITRESULT_PAGE',
  pageNumber
});
