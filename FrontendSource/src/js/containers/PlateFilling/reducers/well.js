/**
 * Created by psindurakar on 12/14/2017.
 */
const well = (state = [], action) => {
  switch (action.type) {
    case 'FETCH_WELL':
      return state;
    case 'WELL_ADD':
      return action.data;
    case 'WELL_REMOVE': {
      let newWell = [];
      newWell = state.filter(d => d.position !== action.position);
      return newWell;
    }
    case 'WELL_EMPTY':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default well;
