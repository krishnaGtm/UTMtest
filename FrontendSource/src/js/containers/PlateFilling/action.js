export const addSelectedCrop = crop => ({
  type: 'ADD_SELECTED_CROP',
  crop
});

export const fetchBreedingStation = () => ({
  type: 'FETCH_BREEDING_STATION'
});

export const breedingStationSelected = selected => ({
  type: 'BREEDING_STATION_SELECTED',
  selected
});

export const testslookupSelected = obj => ({
  type: 'TESTSLOOKUP_SELECTED',
  ...obj
});

export const resetPlatefillingTotal = () => ({
  type: 'RESET_PLATEFELLING_TOTAL'
});

export const dataFillingEmpty = () => ({
  type: 'DATA_FILLING_BULK_ADD',
  data: []
});

export const columnFillingEmpty = () => ({
  type: 'COLUMN_FILLING_BULK_ADD',
  data: []
});

export const fetchSlot = testID => ({
  type: 'FETCH_SLOT',
  testID
});

export const filelistFetch = (breeding, crop) => ({
  type: 'FILELIST_FETCH',
  breeding,
  crop
});

export const fetchTestlookup = (breedingStationCode, cropCode) => ({
  type: 'FETCH_TESTLOOKUP',
  breedingStationCode,
  cropCode
});

export const assignFixPosition = (testID, wellPosition, materialID) => ({
  type: 'ASSIGN_FIX_POSITION',
  testID,
  wellPosition,
  materialID
});


export const fetchWell = testID => ({
  type: 'FETCH_WELL',
  testID
});

export const plateLabelRequest = testID => ({
  type: 'PLATE_LABEL_REQUEST',
  testID
});

export const reserveCall = testID => ({
  type: 'REQUEST_RESERVE_PLATE',
  testID
});

export const sendToLims = testID => ({
  type: 'REQUEST_TO_LIMS',
  testID
});

export const deleteDeadMaterialsCall = testID => ({
  type: 'REQUEST_DEAD_MATERIALS_DELETE',
  testID
});

export const pageSizeChange = pageSize => ({
  type: 'SIZE_PLATE_RECORD',
  pageSize
});

export const filterClear = () => ({
  type: 'FILTER_CLEAR'
});

export const pageRecord = pageNumber => ({
  type: 'PAGE_RECORD',
  pageNumber
});

export const testsLookupConfirmRequest = (testId, statusCode) => ({
  type: 'TESTSLOOKUP_CONFIRM_REQUEST',
  testId,
  statusCode
});

export const saveDB = (testID, materialIDs) => ({
  type: 'ACTION_SAVE_DB',
  testID,
  materialIDs
});

export const testsLookupSelected = id => ({
  type: 'TESTSLOOKUP_SELECTED',
  id
});

export const rootSetAll = (
  testID,
  testTypeID,
  statusCode,
  remark,
  remarkRequired,
  slotID,
  importLevel
) => ({
  type: 'ROOT_SET_ALL',
  testID,
  testTypeID,
  statusCode,
  remark,
  remarkRequired,
  slotID,
  importLevel
});

export const selectMaterialState = id => ({
  type: 'SELECT_MATERIAL_STATE',
  id
});

export const selectMaterialType = id => ({
  type: 'SELECT_MATERIAL_TYPE',
  id
});
