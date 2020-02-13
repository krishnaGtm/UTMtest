const exportList = (state = [], action) => {
  switch (action.type) {
    case 'EXPORT_ADD_BULK':
      return action.data;
    default:
      return state;
  }
};
export default exportList;
