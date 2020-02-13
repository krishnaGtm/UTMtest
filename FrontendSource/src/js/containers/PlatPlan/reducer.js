import { combineReducers } from 'redux';

import {
  FETCH_PLAT_PLAN,
  FILTER_PLAT_PLAN_ADD,

  FILTER_PLAT_PLAN_RESET,
  PLAT_PLAN_BULK,
  PLAT_PLAN_RECORDS,
  PLAT_PLAN_PAGE
} from './constant';

const platPlanData = (state = [], action) => {
  switch(action.type) {
    case PLAT_PLAN_BULK:
      return action.data;
    default:
      return state;
  }
};

const filter = (state = [], action) => {
  switch (action.type) {
    case FILTER_PLAT_PLAN_ADD: {
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
    case FILTER_PLAT_PLAN_RESET:
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};

const init = {
  total: 0,
  pageNumber: 1,
  pageSize: 200
};
const total = (state = init, action) => {
  switch (action.type) {
    case PLAT_PLAN_RECORDS:
      return { ...state, total: action.total };
    case PLAT_PLAN_PAGE:
      return { ...state, pageNumber: action.pageNumber };
    case 'PLAT_PLAN_SIZE':
      return { ...state, pageSize: action.pageSize * 1 };
    default:
      return state;
  }
};

const platPlan = combineReducers({
  platPlanData,
  filter,
  total
});
export default platPlan;
