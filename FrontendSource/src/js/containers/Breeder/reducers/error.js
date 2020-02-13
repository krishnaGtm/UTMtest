const init = {
  error: '',
  submit: false,
  forced: false
};

const Error = (state = init, action) => {
  switch (action.type) {
    case 'BREEDER_ERROR_ADD':
      return Object.assign({}, state, {
        error: action.message
      });

    case 'BREEDER_SUBMIT':
      return Object.assign({}, state, {
        submit: action.submit
      });

    case 'BREEDER_FORCED':
      return Object.assign({}, state, {
        forced: action.forced
      });

    case 'BREEDER_ERROR_CLEAR':
      return '';

    case 'BREEDER_ERROR_TYPE':
    case 'BREEDER_FIELD_FETCH':
    default:
      return state;
  }
};
export default Error;
