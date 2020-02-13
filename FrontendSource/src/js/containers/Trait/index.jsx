import { connect } from 'react-redux';

import TraidComponent from './components/TraitComponent';
import {
  fetchRelation,
  postRelation,
  filterTraitClear,
  filterTraitAdd
} from './action';

import './trait.scss';

const mapState = state => ({
  sideMenu: state.sidemenuReducer,
  relation: state.traitRelation.relation,
  total: state.traitRelation.total.total,
  pagenumber: state.traitRelation.total.pageNumber,
  pagesize: state.traitRelation.total.pageSize,
  filter: state.traitRelation.filter
});
const mapDispatch = dispatch => ({
  // sideMenu: () => dispatch(sidemenuClose()),
  fetchDate: (pageNumber, pageSize, filter) =>
    dispatch(fetchRelation(pageNumber, pageSize, filter)),
  relationChanges: obj => dispatch(postRelation(obj)),
  filterClear: () => dispatch(filterTraitClear()),
  filterAdd: obj => dispatch(filterTraitAdd(obj))
});

export default connect(
  mapState,
  mapDispatch
)(TraidComponent);
