export const pageTitle = () => ({
  type: 'SET_PAGETITLE',
  title: 'Lab Overview'
});

export const fetchYearPeriod = (year, periodID) => ({
  type: 'LAB_OVERVIEW_DATA_FETCH',
  year,
  periodID
});

export const fetchYearPeriodUpdate = (data, year) => ({
  type: 'LAB_OVERVIEW_DATA_UPDATE',
  data,
  year
});
