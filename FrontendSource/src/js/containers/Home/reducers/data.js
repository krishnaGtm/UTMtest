const data = (state = [], action) => {
  switch (action.type) {
    case 'ASSIGNDATA_FETCH':
    case 'UPLOAD_ACTION':
      return state;
    case 'DATA_BULK_ADD':
      return action.data;
    case 'DATA_EMPTY':
    case 'RESET_ASSIGN':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default data;
