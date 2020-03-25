import React from 'react';
import shortid from 'shortid';
import PropTypes from 'prop-types';

import UpdateSlotPeriodModal from '../containers/UpdateSlotPeriodModal';
import SelectPlanPeriod from './SelectPlanPeriod';
import SummaryTable from './SummaryTable';
import DetailsTable from './DetailsTable';

class LabApprovalComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedPeriodID: 0,
      planPeriods: [],
      currentSlotID: null,
      updateSlotPeriodModalVisibility: false,
      calWidth: this.colWidth,
      columnsLength: this.props.columns.length
    };
    this.colWidth = 105;
  }
  componentDidMount() {
    this.props.getPlanPeriods();
    window.addEventListener('resize', this.getNewColWidth);
    this.getNewColWidth();
    // this.props.sidemenu();
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.planPeriods.length !== this.state.planPeriods.length) {
      this.setState({
        planPeriods: nextProps.planPeriods
      });
      const selectedPeriod = nextProps.planPeriods.find(
        period => period.selected
      );
      if (selectedPeriod) {
        this.setState({
          selectedPeriodID: selectedPeriod.periodID
        });
        this.props.getApprovalList(selectedPeriod.periodID);
      }
    }
    if (nextProps.columns.length !== this.props.columns.length) {
      this.setState({
        columnsLength: nextProps.columns.length
      });
      this.getNewColWidth(null, nextProps.columns.length);
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.getNewColWidth);
  }
  getNewColWidth = (e = null, colLength = null) => { // eslint-disable-line
    const { innerWidth } = window;
    const columnsLength = colLength || this.state.columnsLength;
    // hard code
    // 040 wrapper padding
    // 315 (date section)
    // 105 (user col) +
    // 420 (comment section)
    const fixWidth = 950;
    // const fixWidth = 880 + 17;
    if (columnsLength > 0) {
      const newCal = (innerWidth - fixWidth) / columnsLength;
      if (newCal > this.colWidth) {
        this.setState({
          calWidth: Math.ceil(newCal)
        });
      } else if (this.state.calWidth !== 105) {
        this.setState({
          calWidth: 105
        });
      }
    }
  };
  handleChoosePeriodChange = e => {
    this.setState({
      selectedPeriodID: e.target.value * 1
    });
    this.props.getApprovalList(e.target.value);
  };
  showUpdateSlotPeriodModal = slotID => {
    this.setState({
      currentSlotID: slotID,
      updateSlotPeriodModalVisibility: true
    });
  };
  closeUpdateSlotPeriodModal = () => {
    this.setState({
      updateSlotPeriodModalVisibility: false
    });
  };

  render() {
    const {
      columns,
      standard,
      current,
      planPeriods,
      details,
      approveSlot,
      denySlot
    } = this.props;
    const { calWidth } = this.state;
    const columnsName = [];
    const keys = [];
    columns.map(column => {
      columnsName.push(
        <th style={{ width: calWidth }} key={column.testProtocolID}>
          {column.testProtocolName}
        </th>
      );
      keys.push(column.testProtocolID);
      return null;
    });
    return (
      <div className="labApproval">
        <section className="page-action">
          <div className="left">
            <SelectPlanPeriod
              {...{
                onChange: this.handleChoosePeriodChange,
                selectedPeriodID: this.state.selectedPeriodID,
                planPeriods
              }}
            />
          </div>
        </section>
        {/* <div className="fileSection">
          <SelectPlanPeriod
            {...{
              onChange: this.handleChoosePeriodChange,
              selectedPeriodID: this.state.selectedPeriodID,
              planPeriods
            }}
          />
        </div> */}

        <div className="lab-approval-main-wrapper">
          {this.state.updateSlotPeriodModalVisibility && (
            <UpdateSlotPeriodModal
              {...{
                closeModal: this.closeUpdateSlotPeriodModal,
                slotID: this.state.currentSlotID,
                periodID: this.state.selectedPeriodID
              }}
            />
          )}
          {standard.map(standardItem => {
            const currentItem = current.find(
              aItem => aItem.periodID === standardItem.periodID
            );

            const currentPeriodDetails = [];
            // alter 1
            // const currentPeriodDetails = details.filter(
            //   detailsItem => detailsItem.periodID === standardItem.periodID
            // );
            // alert 2
            details.map(
              detailsItem => {
                if (detailsItem.periodID === standardItem.periodID) {
                  currentPeriodDetails.push(detailsItem);
                }
              }
            );
            return (
              <div
                key={shortid.generate()}
                className="lab-approval-table-container"
              >
                <div className="lap-approval-tables-wrapper">
                  <SummaryTable
                    {...{
                      columnsName,
                      keys,
                      standardItem,
                      currentItem,
                      calWidth
                    }}
                  />
                  {currentPeriodDetails.length > 0 && (
                    <DetailsTable
                      {...{
                        columnsName,
                        keys,
                        currentPeriodDetails,
                        periodID: this.state.selectedPeriodID,
                        approveSlot,
                        denySlot,
                        showUpdateSlotPeriodModal: this.showUpdateSlotPeriodModal,
                        standardItem,
                        calWidth
                      }}
                    />
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    );
  }
}
LabApprovalComponent.propTypes = {
  sidemenu: PropTypes.func.isRequired,
  getApprovalList: PropTypes.func.isRequired,
  approveSlot: PropTypes.func.isRequired,
  denySlot: PropTypes.func.isRequired,
  getPlanPeriods: PropTypes.func.isRequired,
  current: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  standard: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  details: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  columns: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  planPeriods: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};

export default LabApprovalComponent;