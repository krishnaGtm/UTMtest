import { combineReducers } from 'redux';

const result = (state = [], action) => {
  switch (action.type) {
    case 'RESULT_ADD': {
      // console.log(action, 'Relation table');
      const {
        cropCode,
        determinationAlias,
        determinationID,
        determinationName,
        determinationValue,
        traitDeterminationResultID,
        traitID,
        traitName,
        traitValue
      } = action;
      return [
        ...state,
        {
          cropCode,
          determinationAlias,
          determinationID,
          determinationName,
          determinationValue,
          traitDeterminationResultID,
          traitID,
          traitName,
          traitValue
        }
      ];
      // return state;
    }
    case 'RESULT_BULK':
      return action.data;
    default:
      return state;
  }
};

const filter = (state = [], action) => {
  switch (action.type) {
    case 'FILTER_TRAITRESULT_ADD': {
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
    case 'FILTER_TRAITRESULT_CLEAR':
    case 'RESETALL':
      return [];
    case 'FETCH_TRAITRESULT_FILTER_DATA':
    case 'FETCH_CLEAR_TRAITRESULT_FILTER_DATA':
    default:
      return state;
  }
};

const traitValues = (state = [], action) => {
  switch (action.type) {
    case 'TRAITVALUE_BULK':
      return action.data;
    case 'TRAITVALUE_RESET':
      return [];
    case 'FETCH_TRAITVALUES':
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
    case 'TRAITRESULT_RECORDS':
      return { ...state, total: action.total };
    case 'TRAITRESULT_PAGE':
      return { ...state, pageNumber: action.pageNumber };
    case 'TRAITRESULT_SIZE':
      return { ...state, pageSize: action.pageSize * 1 };
    default:
      return state;
  }
};

const checkValidation = (state = [], action) => {
  switch (action.type) {
    case 'CHECKVALIDATION_BULK':
      return action.data;
    case 'CHECKVALIDATION_RESET':
      return [];
    case 'FETCH_CHECKVALIDATION':
    default:
      return state;
  }
};

const traitresult = combineReducers({
  result,
  traitValues,
  filter,
  total,
  checkValidation
});
export default traitresult;
