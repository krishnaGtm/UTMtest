/**
 * Created by psindurakar on 12/26/2017.
 */
const ASSIGN_TOTAL_RECORD = 'TOTAL_RECORD';
const ASSIGN_SIZE = 'SIZE_RECORD';
const ASSIGN_PAGE = 'PAGE_RECORD';

const iniAssignMarker = {
  total: 0,
  pageNumber: 1,
  pageSize: 200
};
const total = (state = iniAssignMarker, action) => {
  switch (action.type) {
    case ASSIGN_TOTAL_RECORD:
      return Object.assign({}, state, { total: action.total });
    case ASSIGN_PAGE:
      return Object.assign({}, state, { pageNumber: action.pageNumber });
    case ASSIGN_SIZE:
      return Object.assign({}, state, { pageSize: action.pageSize });
    case 'RESET_ASSIGNMARKER_TOTAL':
    case 'RESETALL':
      return iniAssignMarker;
    case 'NEW_PAGE':
    default:
      return state;
  }
};
export default total;
