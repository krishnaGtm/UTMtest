const getWellTypeID = (state = [], action) => {
  switch (action.type) {
    case 'STORE_WELLTYPEID':
      return action.data;
    case 'FETCH_GETWELLTYPEID':
    default:
      return state;
  }
};
export default getWellTypeID;
