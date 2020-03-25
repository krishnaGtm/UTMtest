import { connect } from 'react-redux';

import PlatPlanComponent from './PlatPlanComponent';

import {
  fetchPlatPlan,
  filterPlatPlanClear,
  filterPlatPlanAdd
} from './action';

const mapState = state => ({
    sideMenu: state.sidemenuReducer,
    relation: state.platPlan.platPlanData,
    total: state.platPlan.total.total,
    pagenumber: state.platPlan.total.pageNumber,
    pagesize: state.platPlan.total.pageSize,
    filter: state.platPlan.filter
});
const mapDispatch = dispatch => ({
    fetchDate: (pageNumber, pageSize, filter) => {
        dispatch(fetchPlatPlan(pageNumber, pageSize, filter));
    },
    filterClear: () => dispatch(filterPlatPlanClear()),
    filterAdd: obj => dispatch(filterPlatPlanAdd(obj)),
});

export default connect(
  mapState,
  mapDispatch
)(PlatPlanComponent);