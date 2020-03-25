export const fetchRelation = (pageNumber, pageSize, filter) => ({
  type: 'GET_RELATION',
  pageNumber,
  pageSize,
  filter
});

export const fetchCrop = () => ({
  type: 'FETCH_CROP'
});

export const fetchTrait = (traitName, cropCode, sourceSelected) => ({
  type: 'FETCH_TRAIT',
  traitName,
  cropCode,
  sourceSelected
});

export const fetchDetermination = (determinationName, cropCode) => ({
  type: 'FETCH_DETERMINATION',
  determinationName,
  cropCode
});

export const postRelation = data => ({
  type: 'POST_RELATION',
  data
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
export const storeCrops = data => ({
  type: 'CROP_ADD',
  data
});

export const storeTrait = data => ({
  type: 'TRAIT_ADD',
  data
});

export const storeDetermination = data => ({
  type: 'DETERMINATION_ADD',
  data
});

export const storeRelation = data => ({
  type: 'RELATION_BULK',
  data
});

export const storeTotal = total => ({
  type: 'TRAIT_RECORDS',
  total
});
export const storePage = pageNumber => ({
  type: 'TRAIT_PAGE',
  pageNumber
});

export const filterTraitClear = () => ({
  type: 'FILTER_TRAIT_CLEAR'
});
export const filterTraitAdd = obj => ({
  type: 'FILTER_TRAIT_ADD',
  name: obj.name,
  value: obj.value,
  expression: 'contains',
  operator: 'and',
  dataType: obj.dataType,
  traitID: obj.traitID
});
