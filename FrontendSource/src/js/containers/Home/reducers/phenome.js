/**
 * Created by sushanta on 4/12/18.
 */
const initialState = {
  isLoggedIn: !!sessionStorage.getItem('isLoggedIn'),
  treeData: {},
  warningFlag: false,
  warningMessage: [],
  existingImport: false
};
const phenome = (state = initialState, action) => {
  switch (action.type) {
    case 'PHENOME_LOGIN_DONE':
      sessionStorage.setItem('isLoggedIn', 'yes');
      return { ...state, isLoggedIn: true };
    case 'GET_RESEARCH_GROUPS_DONE':
    case 'GET_FOLDERS_DONE':
      return { ...state, treeData: action.data };
    case 'PHENOME_LOGOUT':
      return { ...state, isLoggedIn: false };
    case 'PHENOME_WARNING': {
      return Object.assign({}, state, {
        warningFlag: true,
        warningMessage: action.warningMessage
      });
    }
    case 'PHENOME_WARNING_FALSE':
      return Object.assign({}, state, { warningFlag: false, warningMessage: [] });
    case 'PHENOME_EXISTING_IMPORT': {
      alert(action.type);
      return { ...state, existingImport: action.flag };
    }
    default:
      return state;
  }
};
export default phenome;
