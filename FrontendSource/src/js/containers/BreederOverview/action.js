export const slotFetch = (cropCode, brStationCode, pageNumber, pageSize, filter) => ({
  type: 'FETCH_BREEDER_SLOT',
  cropCode,
  brStationCode,
  pageNumber,
  pageSize,
  filter
});

export const clearFilter = () => ({
  type: 'FILTER_BREEDER_SLOT_CLEAR'
});

export const addFilter = (
  name,
  value,
  expression,
  operator,
  dataType,
  traitID
) => ({
  type: 'FILTER_BREEDER_SLOT_ADD',
  name,
  value,
  expression,
  operator,
  dataType,
  traitID
});

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
