export const labCapacityData = data => ({
  type: 'LAB_DATA_ADD',
  data
});

export const labCapacityColumn = data => ({
  type: 'LAB_COLUMN_ADD',
  data
});

export const labFetch = year => ({
  type: 'LAB_DATA_FETCH',
  year
});

export const labDataChange = (index, key, value) => ({
  type: 'LAB_DATA_CHANGE',
  index,
  key,
  value
});

export const labDataRowChange = (key, value) => ({
  type: 'LAB_DATE_ROW_CHANGE',
  key,
  value
});

export const labDataUpdate = (data, year) => ({
  type: 'LAB_DATA_UPDATE',
  data,
  year
});
