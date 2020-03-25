const bInit = {
  station: [],
  selected: ''
};

const breedingStation = (state = bInit, action) => {
  switch (action.type) {
    case 'BREEDING_STATION_STORE':
      return Object.assign({}, state, {
        station: action.data
      });

    case 'BREEDING_STATION_SELECTED':
      return Object.assign({}, state, {
        selected: action.selected
      });

    case 'FETCH_BREEDING_STATION':
    default:
      return state;
  }
};
export default breedingStation;
