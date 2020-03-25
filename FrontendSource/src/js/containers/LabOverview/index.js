import { connect } from 'react-redux';
// import TableOverview from './components/TableOverview';

import LabOverviewComponent from './components/LabOverviewComponent';
import './labOverview.scss';
import { pageTitle, fetchYearPeriod, fetchYearPeriodUpdate } from './actions';
// import { sidemenuClose } from "../../action";

const mapState = state => ({
  sideMenu: state.sidemenuReducer,
  data: state.laboverview.data,
  refresh: state.laboverview.refresh
});
const mapDispatch = dispatch => ({
  // sidemenu: () => dispatch(sidemenuClose()),
  pageTitle: () => {
    dispatch(pageTitle());
  },
  labFetch: (year, period) => {
    dispatch(fetchYearPeriod(year, period));
  },
  labDataUpdate: (data, year) => {
    dispatch(fetchYearPeriodUpdate(data, year));
  },
  slotEdit: (slotID, plannedDate, expectedDate, currentYear) => {
    dispatch({
      type: 'SLOT_EDIT',
      slotID,
      plannedDate,
      expectedDate,
      currentYear
    });
  }
});

const LabOverview = connect(mapState, mapDispatch)(LabOverviewComponent);

export default LabOverview;
