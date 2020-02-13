const token = sessionStorage.getItem('token');
let rr;
let role = [];
if (token) {
  const ab = token.split('.')[1];
  rr = JSON.parse(atob(ab));
  role = rr.role;
}
const init = {
  role,
  selectedCrop: '',
  crops: [],
  exp: sessionStorage.getItem('exp'),
  token
};
// 'handlelabcapacity', 'requesttest'
const user = (state = init, action) => {
  switch (action.type) {
    case 'ADD_ROLE':
      // console.log(action);
      return Object.assign({}, state, {
        exp: action.exp,
        crops: action.crops,
        role: action.role,
        token: action.token
      });
    case 'RESET_ROLE':
      return init;
    case 'ADD_SELECTED_CROP':
      return Object.assign({}, state, {
        selectedCrop: action.crop
      });
    case 'FETCH_TOKEN':
    default:
      return state;
  }
};
export default user;
