import { combineReducers } from 'redux';

const crop = (state = [], action) => {
  switch (action.type) {
    case 'CROP_ADD':
      return action.data;
    default:
      return state;
  }
};

const trait = (state = [], action) => {
  switch (action.type) {
    case 'TRAIT_ADD':
      return action.data;
    default:
      return state;
  }
};

const determination = (state = [], action) => {
  switch (action.type) {
    case 'DETERMINATION_ADD':
      return action.data;
    default:
      return state;
  }
};

const relation = (state = [], action) => {
  switch (action.type) {
    case 'RELATION_ADD':
      console.log(action, 'Relation table');
      return state;
    case 'RELATION_BULK':
      return action.data;
    default:
      return state;
  }
};

const filter = (state = [], action) => {
  switch (action.type) {
    case 'FILTER_TRAIT_ADD': {
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
    case 'FILTER_TRAIT_CLEAR':
    case 'RESETALL':
      return [];
    case 'FETCH_TRAIT_FILTER_DATA':
    case 'FETCH_CLEAR_TRAIT_FILTER_DATA':
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
    case 'TRAIT_RECORDS':
      return { ...state, total: action.total };
    case 'TRAIT_PAGE':
      return { ...state, pageNumber: action.pageNumber };
    case 'TRAIT_SIZE':
      return { ...state, pageSize: action.pageSize * 1 };
    default:
      return state;
  }
};

const traitrelaton = combineReducers({
  crop,
  trait,
  determination,
  relation,
  filter,
  total
});
export default traitrelaton;
