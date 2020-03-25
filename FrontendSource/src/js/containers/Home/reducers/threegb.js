const threegb = (state = [], action) => {
  switch (action.type) {
    case 'THREEGB_DATA_BULK_ADD':
      return action.data;
    case 'RESET_THREEGB':
      return [];
    case 'THREEGB_PROJECTLIST_FETCH':
    case 'THREEGB_UPLOAD_ACTION':
    case 'THREEGB_SEND_COCKPIT':
    default:
      return state;
  }
};
export default threegb;
