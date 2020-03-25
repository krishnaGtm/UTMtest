import { combineReducers } from 'redux';
// import column from './column';
import data from './data';
// import filter from './filter';
const refresh = (state = false, action) => {
  switch (action.type) {
    case 'LABOVERVIEW_REFRESH':
      return !state;
    default:
      return state;
  }
};

const LabOverview = combineReducers({
  data,
  refresh
});
export default LabOverview;
