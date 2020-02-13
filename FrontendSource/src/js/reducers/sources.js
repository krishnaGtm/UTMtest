import { combineReducers } from 'redux';

const selected = (state = 'Phenome', action) => {
  switch (action.type) {
    case 'CHANGE_IMPORTSOURCE':
      return action.source;
    default:
      return state;
  }
};

const list = (state = [], action) => {
  switch (action.type) {
    case 'ADD_SOURCE':
      return action.data;
    default:
      return state;
  }
};

export default combineReducers({
  list,
  selected
});
