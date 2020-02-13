/**
 * Created by psindurakar on 12/14/2017.
 */
import { combineReducers } from 'redux';

const initTestslookup = {
  testID: null,
  testName: '',
  testTypeID: null,
  testTypeName: '',
  remark: '',
  remarkRequired: '',
  statusCode: '',

  materialStateID: null,
  materialTypeID: null,

  slotId: null,
  slotName: '',

  wellsPerPlate: null,
  platePlanName: '',
  source: ''
};
const selected = (state = initTestslookup, action) => {
  switch (action.type) {
    case 'TESTSLOOKUP_SELECTED': {
      // console.log(action);
      const {
        testID,
        testName,
        testTypeID,
        testTypeName,
        remark,
        remarkRequired,
        statusCode,
        materialStateID,
        materialTypeID,
        slotID,
        slotName,
        wellsPerPlate,
        platePlanName,
        source,
        importLevel
      } = action;
      return {
        testID,
        testName,
        testTypeID,
        testTypeName,
        remark,
        remarkRequired,
        statusCode,
        materialStateID,
        materialTypeID,
        slotID,
        slotName,
        wellsPerPlate,
        platePlanName,
        source,
        importLevel
      };
    }
    case 'ROOT_STATUS':
      return { ...state, statusCode: action.statusCode };
    case 'ROOT_SLOTID':
      return { ...state, slotID: action.slotID };
    case 'TESTSLOOKUP_SET_REMARK':
      return { ...state, remark: action.remark };
    case 'TESTSLOOKUP_RESET_ALL':
      return initTestslookup;
    default:
      return state;
  }
};

const list = (state = [], action) => {
  switch (action.type) {
    case 'FETCH_TESTLOOKUP':
      return state;
    case 'TESTSLOOKUP_SET_REMARK':
      return state.map(test => {
        if (test.testID === action.testID) {
          return { ...test, remark: action.remark };
        }
        return test;
      });
    case 'ROOT_STATUS':
      return state.map(test => {
        if (test.testID === action.testID) {
          return { ...test, statusCode: action.statusCode };
        }
        return test;
      });
    case 'ROOT_SLOTID':
      return state.map(slot => {
        if (slot.testID === action.testID) {
          return { ...slot, slotID: action.slotID };
        }
        return slot;
      });
    case 'TESTSLOOKUP_SET_FIXEDPOSITION_CHANGE':
      return state.map(test => {
        if (test.testID === action.testID) {
          return { ...test, fixedPostionAssigned: true };
        }
        return test;
      });

    case 'TESTSLOOKUP_ADD': {
      const newData = action.data.filter(
        x => x.testTypeID !== 4 && x.testTypeID !== 5
      );
      // console.log(newData);
      return newData;
      // return action.data;
    }
    case 'TESTSLOOKUP_RESET_ALL':
      // console.log('case TESTSLOOKUP_RESET_ALL:');
      return [];
      // action will fire from Assign Marker delete test button
    case 'REMOVE_FILE_AFTER_DELETE':
      return state.filter(x => x.testID !== action.testID);
    case 'TESTSLOOKUP_CONFIRM_REQUEST':
    default:
      return state;
  }
};

const testsLookup = combineReducers({
  list,
  selected
});
export default testsLookup;
