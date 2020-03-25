/**
 * Created by sushanta on 3/14/18.
 */
const initialState = {
  columns: [],
  current: [],
  standard: [],
  details: []
};
const approvalList = (state = initialState, action) => {
  switch (action.type) {
    case 'GET_APPROVAL_LIST_DONE':
      return {
        ...state,
        columns: action.data.columns,
        current: action.data.current,
        standard: action.data.standard,
        details: action.data.details
      };
    default:
      return state;
  }
};
export default approvalList;
