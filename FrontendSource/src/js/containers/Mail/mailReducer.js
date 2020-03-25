import { combineReducers } from 'redux';

const initMail = [];
const data = (state = initMail, action) => {
  switch (action.type) {
    case 'MAIL_ADD': {
      // console.log(action, 'Relation table');
      return action.data;
      const {
        cropCode,
        determinationAlias,
        determinationID,
        determinationName,
        determinationValue,
        traitDeterminationResultID,
        traitID,
        traitName,
        traitValue
      } = action;
      return [
        ...state,
        {
          cropCode,
          determinationAlias,
          determinationID,
          determinationName,
          determinationValue,
          traitDeterminationResultID,
          traitID,
          traitName,
          traitValue
        }
      ];
      // return state;
    }
    case 'MAIL_BULK':
      return action.data;
    default:
      return state;
  }
};

const init = {
  total: 0,
  pageNumber: 1,
  pageSize: 50,
  refresh: false
};
const total = (state = init, action) => {
  switch (action.type) {
    case 'MAIL_RECORDS':
      return { ...state, total: action.total };
    case 'MAIL_PAGE':
      return { ...state, pageNumber: action.pageNumber };
    case 'MAIL_SIZE':
      return { ...state, pageSize: action.pageSize * 1 };

    case 'MAIL_BULK':
      return { ...state, refresh: !state.refresh };
    default:
      return state;
  }
};
const mailRecipients = combineReducers({
  data,
  total
});
export default mailRecipients;
