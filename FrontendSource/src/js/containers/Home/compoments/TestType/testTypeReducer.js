/**
 * Created by psindurakar on 12/14/2017.
 */
import { combineReducers } from 'redux';

const FETCH_TESTTYPE = 'FETCH_TESTTYPE';
const TESTTYPE_ADD = 'TESTTYPE_ADD';
const TESTTYPE_SELECTED = 'TESTTYPE_SELECTED';

const selected = (state = null, action) => {
  switch (action.type) {
    case TESTTYPE_SELECTED:
      return action.id;
    default:
      return state;
  }
};

const list = (state = [], action) => {
  switch (action.type) {
    case FETCH_TESTTYPE:
      return state;
    case TESTTYPE_ADD:
      return action.data;
    default:
      return state;
  }
};
const testType = combineReducers({
  list,
  selected
});
export default testType;
