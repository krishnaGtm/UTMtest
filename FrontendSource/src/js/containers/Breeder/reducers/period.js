const init = {
  planned: '',
  expected: '',
  availPlates: 0,
  availTests: 0,
  expectedDate: null
};
const Period = (state = init, action) => {
  switch (action.type) {
    case 'ADD_PERIOD':
      return action.data;

    case 'PERIOD_ADD':
      console.log(action);
      return Object.assign({}, state, {
        planned: action.period
      });

    case 'EXPECTED_ADD':
      return Object.assign({}, state, {
        expected: action.period
      });

    case 'AVAIPLATES_ADD':
      return Object.assign({}, state, {
        availPlates: action.availPlates
      });

    case 'AVAITESTS_ADD':
      return Object.assign({}, state, {
        availTests: action.availTests
      });

    case 'EXPECTED_DATE':
      return Object.assign({}, state, {
        expectedDate: action.expectedDate
      });
    case 'EXPECTED_BLANK':
      return Object.assign({}, state, {
        expectedDate: '',
        expected: '',
        availPlates: 0,
        availTests: 0
      });
    case 'BREEDER_RESET':
      return init;

    case 'PERIOD_FETCH':
    case 'PLATES_TESTS_FETCH':
    default:
      return state;
  }
};
export default Period;
