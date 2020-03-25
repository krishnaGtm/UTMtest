const plant = (state = [], action) => {
  switch (action.type) {
    case 'PLANT_BULK_ADD':
      return action.data;
    case 'PLANT_EMPTY':
      return [];
    case 'FETCH_PLANT':
    default:
      return state;
  }
};
export default plant;
