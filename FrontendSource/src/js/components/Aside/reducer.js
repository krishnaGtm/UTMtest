const sidemenuReducer = (state = false, action) => {
  switch (action.type) {
    case 'TOGGLE_SIDEMENU': {
      const body = document.getElementsByTagName('body');
      if (!state) {
        body[0].style.overflowX = 'hidden';
      } else {
        body[0].style.overflowX = 'visible';
      }
      return !state;
    }
    case 'ASSIGN_SIDEMENU':
      return action.status;
    default:
      return state;
  }
};
export default sidemenuReducer;
