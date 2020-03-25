const statusList = (state = [], action) => {
  switch (action.type) {
    case 'STORE_STATUS':
      return action.data;
    case 'FETCH_STATULSLIST':
    default:
      return state;
  }
};
export default statusList;
