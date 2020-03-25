const materialState = (state = [], action) => {
  switch (action.type) {
    case 'STORE_MATERIAL_STATE':
      return action.data.map(d => ({ ...d, selected: false }));

    case 'SELECT_MATERIAL_STATE':
      return state.map(d => {
        if (d.materialStateID === action.id) {
          return { ...d, selected: true };
        }
        return { ...d, selected: false };
      });
    case 'FETCH_MATERIAL_STATE':
    default:
      return state;
  }
};
export default materialState;
