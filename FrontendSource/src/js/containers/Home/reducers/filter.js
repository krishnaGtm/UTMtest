/**
 * Created by psindurakar on 11/29/2017.
 */
const filterReducer = (state = [], action) => {
  switch (action.type) {
    case 'FETCH_FILTERED_DATA':
    case 'FETCH_CLEAR_FILTER_DATA':
      return state;
    case 'FILTER_ADD': {
      const check = state.find(d => d.name === action.name);
      if (check) {
        return state.map(filter => {
          if (filter.name === action.name) {
            return { ...filter, value: action.value };
          }
          return filter;
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
    case 'FILTER_CLEAR':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default filterReducer;
