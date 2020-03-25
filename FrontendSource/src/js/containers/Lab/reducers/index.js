import { combineReducers } from 'redux';
import column from './column';
import data from './data';

const Lab = combineReducers({
  column,
  data
});
export default Lab;
