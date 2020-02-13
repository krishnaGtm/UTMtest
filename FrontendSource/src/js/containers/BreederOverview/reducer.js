import { combineReducers } from 'redux';

/*
const intSlotFilter = [
  {
    dataType: "NVARCHAR(255)",
    expression: "contains",
    name: "cropCode",
    operator: 'and',
    value: 'lt'
  }
];
*/
const filter = (state = [], action) => {
  switch (action.type) {
    case 'FILTER_BREEDER_SLOT_ADD': {
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
    case 'BREEDER_SLOT_PAGE_RESET':
    case 'FILTER_BREEDER_SLOT_CLEAR':
    case 'RESETALL':
      return [];
    case 'FETCH_BREEDER_SLOT_FILTER_DATA':
    case 'FETCH_CLEAR_BREEDER_SLOT_FILTER_DATA':
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
    case 'BREEDER_SLOT_TOTAL':
      return { ...state, total: action.total };
    case 'BREEDER_SLOT_PAGE':
      return { ...state, pageNumber: action.pageNumber };
    case 'BREEDER_SLOT_SIZE':
      return { ...state, pageSize: action.pageSize * 1 };
    case 'BREEDER_SLOT_PAGE_RESET':
    case 'RESETALL':
      return init;
    default:
      return state;
  }
};

const slot = (state = [], action) => {
  switch (action.type) {
    case 'BREEDER_SLOT': {
      return action.data;
    }
    case 'BREEDER_SLOT_PAGE_RESET':
      return [];
    case 'FETCH_BREEDER_SLOT':
    default:
      return state;
  }
};

const slotBreeder = combineReducers({
  slot,
  filter,
  total
});
export default slotBreeder;
