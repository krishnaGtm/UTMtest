const init = {
  breedingStation: [],
  crop: [],
  materialState: [],
  materialType: [],
  period: [],
  testType: []
};
const Fields = (state = init, action) => {
  switch (action.type) {
    case 'BREEDER_FORM_VALUE':
      return Object.assign({}, state, {
        breedingStation: action.data.breedingStation,
        crop: action.data.crop,
        materialState: action.data.materialState,
        period: action.data.period,
        testType: action.data.testType
      });

    case 'BREEDER_MATERIALTYPE':
      // console.log(action);
      return Object.assign({}, state, {
        materialType: action.materialType
      });

    case 'BREEDER_FORM_CLEAR':
      return [];

    case 'BREEDER_FORM_FETCH':
    case 'BREEDER_FETCH_MATERIALTYPE':
    case 'BREEDER_RESERVE':
    default:
      return state;
  }
};
export default Fields;
