/**
 * Created by psindurakar on 11/29/2017.
 */
/* let init = {
    name: 'Crop',
    value: 'PRO',
    expression: 'contains',
    operator: 'and',
    dataType: 'NVARCHAR(255)',
} */
const filter = (state = [], action) => {
  switch (action.type) {
    case 'FILTER_PLATE_ADD': {
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
    case 'FILTER_PLATE_CLEAR':
    case 'RESETALL':
      return [];
    case 'FETCH_PLATE_FILTER_DATA':
    case 'FETCH_CLEAR_PLATE_FILTER_DATA':
    default:
      return state;
  }
};
export default filter;
