/**
 * Created by psindurakar on 1/8/2018.
 */

const punchList = (state = [], action) => {
  switch (action.type) {
    case 'ADD_PUNCHLIST':
      return action.data;
    case 'FETCH_PUNCHLIST':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default punchList;
