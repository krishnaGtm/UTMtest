/**
 * Created by sushanta on 3/14/18.
 */
import { connect } from 'react-redux';
import LabApprovalComponent from './components/LabApprovalComponent';
import {
  getApprovalList,
  getPlanPeriods,
  approveSlot as approveSlotAction,
  denySlot as denySlotAction
} from './actions';
import { sidemenuClose } from '../../action';
import './index.scss';

const mapStateToProps = state => ({
  current: state.approvalList.current,
  standard: state.approvalList.standard,
  details: state.approvalList.details,
  columns: state.approvalList.columns,
  planPeriods: state.planPeriods
});
const mapDispatchToProps = {
  sidemenu: sidemenuClose,
  getApprovalList,
  getPlanPeriods,
  approveSlot: approveSlotAction,
  denySlot: denySlotAction
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(LabApprovalComponent);
