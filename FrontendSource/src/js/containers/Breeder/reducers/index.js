import { combineReducers } from 'redux';

import error from './error';
import fields from './field';
import period from './period';

const filter = (state = [], action) => {
  switch (action.type) {
      case 'FILTER_BREEDER_ADD': {
        const check = state.find(d => d.name === action.name);
        if (check) {
          return state.map(item => {
            if (item.name === action.name) {
              return { ...item, value: action.value };
            }
            return item;
          });
        }
        return [
          ...state,
          {
            name: action.name,
            value: action.value,
            expression: action.expression,
            operator: action.operator,
            dataType: action.dataType
          }
        ];
      }
      case 'BREEDER_PAGE_RESET':
      case 'FILTER_BREEDER_CLEAR':
      case 'RESETALL':
        return [];
      case 'FETCH_BREEDER_FILTER_DATA':
      case 'FETCH_CLEAR_BREEDER_FILTER_DATA':
      default:
        return state;
    }
}
const data = (state = [], action) => {
  switch (action.type) {
      case 'BREEDER': {
        return action.data;
      }
      case 'BREEDER_PAGE_RESET':
        return [];
      case 'FETCH_BREEDER':
      default:
        return state;
    }
}
const init = {
  total: 0,
  pageNumber: 1,
  pageSize: 200
};
const total = (state = init, action) => {
  switch (action.type) {
    case 'BREEDER_TOTAL':
      return { ...state, total: action.total };
    case 'BREEDER_PAGE':
      return { ...state, pageNumber: action.pageNumber };
    case 'BREEDER_SIZE':
      return { ...state, pageSize: action.pageSize * 1 };
    case 'BREEDER_PAGE_RESET':
    case 'RESETALL':
      return init;
    default:
      return state;
  }
};

const Breeder = combineReducers({
  fields,
  error,
  period,

  filter,
  data,
  total
});

export default Breeder;
