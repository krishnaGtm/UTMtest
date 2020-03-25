import { connect } from 'react-redux';
import TraitResultComponent from './components/TraitResultComponent';

import '../Trait/trait.scss';
import {
  getResults,
  postData,
  resetFilter,
  getCheckValidation,
  resetCheckValidation
} from './action';

const mapState = state => ({
  sideMenu: state.sidemenuReducer,
  result: state.traitResult.result,
  total: state.traitResult.total.total,
  pagenumber: state.traitResult.total.pageNumber,
  pagesize: state.traitResult.total.pageSize,
  filter: state.traitResult.filter,
  checkList: state.traitResult.checkValidation
});
const mapDispatch = dispatch => ({
  // sidemenu: () => dispatch(sidemenuClose()),
  fetchData: (pageNumber, pageSize, filter) =>
    dispatch(getResults(pageNumber, pageSize, filter)),
  resultChanges: (cropCode, data, pageNumber, pageSize, filter) => {
    // console.log('onAddResult', obj);
    // console.log('resultchanes', cropCode, data, pageNumber, pageSize, filter);
    const newObj = {
      cropCode,
      data,
      pageNumber,
      pageSize,
      filter
    };
    dispatch(postData(newObj));
  },
  filterClear: () => dispatch(resetFilter()),
  filterAdd: obj => {
    dispatch({
      type: 'FILTER_TRAITRESULT_ADD',
      name: obj.name,
      value: obj.value,
      expression: 'contains',
      operator: 'and',
      dataType: obj.dataType,
      traitID: obj.traitID
    });
  },
  checkValidation: source => dispatch(getCheckValidation(source)),
  checkValidationClear: () => dispatch(resetCheckValidation())
});

export default connect(
  mapState,
  mapDispatch
)(TraitResultComponent);
