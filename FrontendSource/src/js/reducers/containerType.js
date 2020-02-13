const containerType = (state = [], action) => {
  switch (action.type) {
    case 'STORE_CONTAINER_TYPE':
      return action.data.map(d => ({ ...d, selected: false }));

    case 'SELECT_CONTAINER_TYPE':
      return state.map(d => {
        if (d.containerTypeID === action.id) {
          return { ...d, selected: true };
        }
        return { ...d, selected: false };
      });
    case 'FETCH_CONTAINER_TYPE':
    default:
      return state;
  }
};
export default containerType;
