/**
 * Created by sushanta on 3/27/18.
 */
import React from 'react';
import { connect } from 'react-redux';
import shortid from 'shortid';
import moment from 'moment';
import DatePicker from 'react-datepicker';
import PropTypes from 'prop-types';
import { updateSlotPeriod } from '../actions';
import Wrapper from '../../../components/Wrapper/wrapper';

class LabOverviewSlotUpdateModal extends React.Component {
  constructor(props) {
    super(props);
    // const currentSlotDetails = props.details.find(
    //   item => item.slotID === props.slotID
    // );
    this.state = {
      today: moment(),
      plannedPeriod: moment(props.plannedDate, window.userContext.dateFormat),
      expectedPeriod: moment(props.expectedDate, window.userContext.dateFormat)
    };
  }
  handlePlannedDateChange = date => {
    this.setState({
      plannedPeriod: date,
      expectedPeriod: moment(date).add(2, 'weeks')
    });
  };
  handleExpectedDateChange = date => {
    this.setState({
      expectedPeriod: date
    });
  };
  render() {
    const { closeModal, slotID, columns, details, periodID, slotName } = this.props;
    const { today, plannedPeriod } = this.state;
    const columnsName = [];
    const keys = [];
    // const rangeDate = plannedPeriod ? plannedPeriod : today;
    // console.log(today.diff(plannedPeriod));
    // console.log(234);
    // columns.map(column => {
    //   columnsName.push(
    //     <span key={column.testProtocolID}>{column.testProtocolName}</span>
    //   );
    //   keys.push(column.testProtocolID);
    //   return null;
    // });
    // const currentSlotDetails = details.find(item => item.slotID === slotID);
    return (
      <Wrapper>
        <div className="modalContent">
          <div className="modalTitle">
            <span>&nbsp;&nbsp;&nbsp;&nbsp;Edit ({slotName})</span>
            <i
              role="button"
              className="demo-icon icon-cancel close"
              onClick={() => closeModal()}
              title="Close"
            />
          </div>

          <div className="modelsubtitle">
            <div>
              <label>Planned Week</label>
                <DatePicker
                  selected={this.state.plannedPeriod}
                  minDate={today}
                  onChange={this.handlePlannedDateChange}
                  dateFormat={window.userContext.dateFormat}
                  showWeekNumbers
                  locale="en-gb"
                />
              {/*<span>
              </span>*/}
            </div>
            </div>
          <div className="modelsubtitle">
            <div>
              <label>Expected Week</label>
              <span>
               <DatePicker
                  selected={this.state.expectedPeriod}
                  minDate={plannedPeriod}
                  onChange={this.handleExpectedDateChange}
                  dateFormat={window.userContext.dateFormat}
                  showWeekNumbers
                  locale="en-gb"
                />
              </span>
            </div>
            <div>
              <br />
              <span className="span-with-update-btn">

              </span>
            </div>
          </div>
          <div className="modalFooter">
            <button
              onClick={() => {
                if (this.state.plannedPeriod === null) return;
                this.props.updateSlot(
                  slotID,
                  this.state.plannedPeriod.format(
                    window.userContext.dateFormat
                  ),
                  this.state.expectedPeriod.format(
                    window.userContext.dateFormat
                  ),
                  this.props.currentYear
                );
                closeModal();
              }}
            >
              Update
            </button>
          </div>
          {/*<div className="update-slot-period-modal-footer"> </div>*/}
        </div>
      </ Wrapper>
    );
  }
}
export default LabOverviewSlotUpdateModal;
// const mapStateToProps = state => ({
//   details: state.approvalList.details,
//   columns: state.approvalList.columns
// });
// const mapDispatchToProps = {
//   updateSlotPeriod
// };
// LabOverviewSlotUpdateModal.defaultProps = {
//   slotID: null
// };
// LabOverviewSlotUpdateModal.propTypes = {
//   closeModal: PropTypes.func.isRequired,
//   updateSlotPeriod: PropTypes.func.isRequired,
//   periodID: PropTypes.number.isRequired,
//   slotID: PropTypes.number,
//   details: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
//   columns: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
// };
// export default connect(mapStateToProps, mapDispatchToProps)(
//   LabOverviewSlotUpdateModal
// );
