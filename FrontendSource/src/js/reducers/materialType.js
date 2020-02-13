const materialType = (state = [], action) => {
  switch (action.type) {
    case 'STORE_MATERIAL_TYPE':
      return action.data.map(d => ({ ...d, selected: false }));
    case 'SELECT_MATERIAL_TYPE':
      return state.map(d => {
        if (d.materialTypeID === action.id) {
          return { ...d, selected: true };
        }
        return { ...d, selected: false };
      });
    case 'FETCH_MATERIAL_TYPE':
    default:
      return state;
  }
};
export default materialType;
