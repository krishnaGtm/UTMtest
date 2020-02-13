import { combineReducers } from 'redux';
import column from './column';
import data from './data';
import filter from './filter';
import total from './total';
import testsLookup from './testsLookup';
import plant from './plant';
import well from './well';
import punchlist from './punchlist';

const plateFilling = combineReducers({
  column,
  data,
  filter,
  total,
  testsLookup,
  plant,
  well,
  punchlist
});
export default plateFilling;
