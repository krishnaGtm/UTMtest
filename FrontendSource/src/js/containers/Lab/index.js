import { connect } from 'react-redux';

import LabComponent from './components/LabComponent';
import './labCapacity.scss';
import { labFetch, labDataChange, labDataRowChange, labDataUpdate } from './action';
import { setPageTitle, sidemenuClose } from '../../action';

const mapState = state => ({ data: state.lab.data });
const mapDispatch = dispatch => ({
  pageTitle: () => dispatch(setPageTitle('Lab Capacity')),
  sidemenu: () => dispatch(sidemenuClose()),
  labFetch: year => dispatch(labFetch(year)),
  labDataChange: (index, key, value) => dispatch(labDataChange(index, key, value)),
  labDataRowChange: (key, value) => dispatch(labDataRowChange(key, value)),
  labDataUpdate: (data, year) => dispatch(labDataUpdate(data, year))
});

export default connect(mapState, mapDispatch)(LabComponent);
