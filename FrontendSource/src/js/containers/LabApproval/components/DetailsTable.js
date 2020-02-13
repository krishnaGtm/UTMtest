/**
 * Created by sushanta on 3/29/18.
 */
import React from 'react';
import PropTypes from 'prop-types';
import shortid from 'shortid';
import ConfirmBox from '../../../components/Confirmbox/confirmBox';

class DetailsTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      approveSlotConfirmBoxVisibility: false,
      denySlotConfirmBoxVisibility: false,
      currentSlotID: null
    };
  }
  handleSlotApproval = condition => {
    if (condition) {
      // alert('yes');
      console.log('YES', this.state);
      this.props.approveSlot(this.state.currentSlotID, this.props.periodID);
    }
    this.setState({
      approveSlotConfirmBoxVisibility: false
    });
  };
  handleSlotDenial = condition => {
    if (condition) {
      this.props.denySlot(this.state.currentSlotID, this.props.periodID);
    }
    this.setState({
      denySlotConfirmBoxVisibility: false
    });
  };
  render() {
    const {
      columnsName,
      currentPeriodDetails,
      keys,
      showUpdateSlotPeriodModal,
      standardItem,
      calWidth
    } = this.props;

    return (
      <div className="lab-approval-table lab-approval-details-table">
        {this.state.approveSlotConfirmBoxVisibility && (
          <ConfirmBox
            click={this.handleSlotApproval}
            message="Do you really want to approve this slot?"
          />
        )}
        {this.state.denySlotConfirmBoxVisibility && (
          <ConfirmBox
            click={this.handleSlotDenial}
            message="Do you really want to deny this slot?"
          />
        )}
        <table>
          <thead
            style={
              currentPeriodDetails.length > 5 ? { overflowY: 'scroll' } : {}
            }
          >
            <tr>
              <th>Actions</th>
              <th>Slot Name</th>
              <th>User</th>
              {columnsName}
              <th>&gt;1 week</th>
              <th>#Markers</th>
              <th>#Plates</th>
              <th>Method</th>
            </tr>
          </thead>
          <tbody>
            {currentPeriodDetails.map(periodDetailsItem => {
              return (
                <tr key={shortid.generate()}  t={periodDetailsItem.slotID}>
                  <td>
                    <i
                      role="button"
                      tabIndex="0"
                      onKeyDown={() => {}}
                      onClick={() => {
                        // console.log(periodDetailsItem.slotID);
                        this.setState({
                          approveSlotConfirmBoxVisibility: true,
                          currentSlotID: periodDetailsItem.slotID
                        });
                      }}
                      title="Approve Slot"
                      className="icon icon-ok-circled lab-approval-approve-slot"
                    />{' '}
                    <i
                      role="button"
                      tabIndex="0"
                      onKeyDown={() => {}}
                      onClick={() => {
                        this.setState({
                          denySlotConfirmBoxVisibility: true,
                          currentSlotID: periodDetailsItem.slotID
                        });
                      }}
                      title="Deny Slot"
                      className="icon icon-cancel lab-approval-deny-slot"
                    />{' '}
                    <i
                      role="button"
                      tabIndex="0"
                      onKeyDown={() => {}}
                      onClick={() =>
                        showUpdateSlotPeriodModal(periodDetailsItem.slotID)
                      }
                      title="Update Slot Period"
                      className="icon icon-pencil lab-approval-update-slot"
                    />
                  </td>
                  <td className="fixed-one">{periodDetailsItem.slotName}</td>
                  <td className="fixed-one">
                    {periodDetailsItem.requestUser.split('\\')[1] ||
                      periodDetailsItem.requestUser}
                  </td>
                  {keys.map(key => (
                    <td
                      style={{
                        width: calWidth,
                        color:
                          periodDetailsItem &&
                          periodDetailsItem[key] > standardItem[key]
                            ? 'red'
                            : ''
                      }}
                      key={shortid.generate()}
                    >
                      {periodDetailsItem ? periodDetailsItem[key] || '' : ''}
                    </td>
                  ))}
                  <td
                    style={{
                      color: periodDetailsItem.totalWeeks > 1 ? '' : 'red'
                    }}
                  >
                    {periodDetailsItem.totalWeeks > 1 ? 'Yes' : 'No'}
                  </td>
                  <td>{periodDetailsItem.markers}</td>
                  <td>{periodDetailsItem.plates}</td>
                  <td className="fixed-one">{periodDetailsItem.testProtocolName}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    );
  }
}
DetailsTable.defaultProps = {
  calWidth: null
};
DetailsTable.propTypes = {
  currentPeriodDetails: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  columnsName: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  keys: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  standardItem: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  approveSlot: PropTypes.func.isRequired,
  denySlot: PropTypes.func.isRequired,
  showUpdateSlotPeriodModal: PropTypes.func.isRequired,
  periodID: PropTypes.number.isRequired,
  calWidth: PropTypes.number
};
export default DetailsTable;
