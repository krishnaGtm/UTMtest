/**
 * Created by psindurakar on 12/27/2017.
 */
const PLATE_TOTAL_RECORD = 'TOTAL_PLATE_RECORD';
const ASSIGN_SIZE = 'SIZE_PLATE_RECORD';
const ASSIGN_PAGE = 'PAGE_PLATE_RECORD';

const init = {
  total: 0,
  pageNumber: 1,
  pageSize: 200,
  selectedRow: null,
  wellsPerPlate: null
};
const total = (state = init, action) => {
  switch (action.type) {
    case PLATE_TOTAL_RECORD:
      return { ...state, total: action.total };
    case ASSIGN_PAGE:
      return { ...state, pageNumber: action.pageNumber };
    case ASSIGN_SIZE:
      return { ...state, pageSize: action.pageSize * 1 };
    case 'ASSIGN_WELL_SIZE':
      return { ...state, wellsPerPlate: action.wellsPerPlate * 1 };
    case 'RESET_PLATEFELLING_TOTAL':
    case 'RESETALL':
      return init;
    case 'NEW_PLATE_PAGE':
    default:
      return state;
  }
};
export default total;
