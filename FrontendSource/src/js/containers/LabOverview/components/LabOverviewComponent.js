import React from 'react';
import PropTypes from 'prop-types';

import moment from 'moment';

import PHTable from '../../../components/PHTable/';
import { getDim } from '../../../helpers/helper';
import LabOverviewSlotUpdateModal from '../containers/LabOverviewSlotUpdateModal';

class LabOverviewComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 900,
      tblHeight: 600,
      periods: {},
      startYear: 2015, // why hard coded ???
      endYear: 2030, // why hard coded ???
      currentYear: new Date().getFullYear(),
      filteredData: props.data,

      updatePlan: false,
      plannedDate: '',
      expectedDate: '',
      slotName: '',
      slotID: '',
      refresh: props.refresh
    };
    const dd = new Date();
    this.currentYear = dd.getFullYear();
    this.props.pageTitle();
  }

  componentDidMount() {
    window.addEventListener('beforeunload', this.handleWindowClose);
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
    // this.props.sidemenu();
    // fetch lab overview data
    this.props.labFetch(this.state.currentYear);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.refresh !== this.props.refresh) {
    // }
    // TODO: should have been checked for data update flag
    // if (nextProps.data.length !== this.props.data.length) {
      this.updateDimensions();
      const periods = {};
      nextProps.data.forEach(data => {
        if (periods[data.periodID] === undefined) {
          periods[data.periodID] = data.periodName;
        }
      });
      this.setState({
        refresh: nextProps.refresh,
        periods,
        filteredData: nextProps.data,
      });
    } else {
      // TODO: remove if else condtion
      const periods = {};
      this.props.data.forEach(data => {
        if (periods[data.periodID] === undefined) {
          periods[data.periodID] = data.periodName;
        }
      });
      this.setState({
        refresh: nextProps.refresh,
        periods,
        filteredData: this.props.data
      });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.handleWindowClose);
    window.removeEventListener('resize', this.updateDimensions);
  }

  updateDimensions = () => {
    const dim = getDim();
    // console.log(dim);
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  };

  changeYear = e => {
    this.updateDimensions();
    this.currentYear = e.target.value;
    this.props.labFetch(e.target.value, '');
  };

  changePeriod = e => {
    let filteredData = this.props.data;
    const currentPeriod = parseInt(e.target.value, 10);
    if (e.target.value) {
      filteredData = this.props.data.filter(
        record => record.periodID === currentPeriod
      );
    }
    this.setState({ filteredData });
  };

  // SELECTING SLOT
  editSlot = slotIndex => {
    // alert(slotID);
    const { filteredData } = this.state;
    const { expectedDate, planneDate, slotID, slotName } = filteredData[slotIndex];
    // console.log(filteredData[slotIndex]);
    this.setState({
      updatePlan: true,
      plannedDate: planneDate,
      expectedDate,
      slotID,
      slotName
    });
  };

  closeModal = () => {
    // console.log('close fire');
    this.setState({
      updatePlan: false
    });
  };

  render() {
    let { tblHeight, updatePlan } = this.state;
    const { tblWidth, startYear, endYear, periods, slotID, slotName } = this.state;
    const yearList = [];
    for (let i = startYear; i <= endYear; i += 1) {
      yearList.push(
        <option key={i} value={i}>
          {i}
        </option>
      );
    }

    tblHeight -= 120;

    const columns = [
      'Action',
      'periodName',
      'slotName',
      'breedingStationCode',
      'cropName',
      'requestUser',
      'markers',
      'plates',
      'testProtocolName'
    ];
    const columnsMapping = {
      Action: {
        name: 'Action',
        filter: false,
        fixed: false
      },
      periodName: {
        name: 'Week',
        filter: false,
        fixed: true
      },
      slotName: {
        name: 'Reservation Ticket No',
        filter: false,
        fixed: true
      },
      breedingStationCode: {
        name: 'Breeding station',
        filter: false,
        fixed: true
      },
      cropName: {
        name: 'Crop',
        filter: false,
        fixed: true
      },
      requestUser: {
        name: 'Requester',
        filter: false,
        fixed: true
      },
      markers: {
        name: '#tests',
        filter: false,
        fixed: false
      },
      plates: {
        name: '#plates',
        filter: false,
        fixed: false
      },
      testProtocolName: {
        name: 'Method',
        filter: false,
        fixed: false
      }
    };
    // hard coded for current data widths
    const columnsWidth = {
      Action: 70,
      periodName: 240,
      slotName: 160,
      breedingStationCode: 120,
      cropName: 80,
      requestUser: 200,
      markers: 80,
      plates: 80,
      testProtocolName: 80
    };

    return (
      <div className="labove rview traitContainer">
        <section className="page-action">
          <div className="left">
            <div className="form-e">
              <label htmlFor="year">Year</label>
              <select
                id="year"
                name="year"
                onChange={this.changeYear}
                defaultValue={this.state.currentYear}
              >
                {yearList}
              </select>
            </div>
            <div className="form-e">
              <label>Period</label>
              <select id="period" name="period" onChange={this.changePeriod} className="w-300">
                <option value="">All Periods</option>
                {Object.keys(periods).map(periodID => (
                  <option key={periodID} value={periodID}>
                    {periods[periodID]}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </section>

        <div className="container">
          <PHTable
            sideMenu={this.props.sideMenu}
            filter={[]}
            tblWidth={tblWidth}
            tblHeight={tblHeight}
            columns={columns}
            data={this.state.filteredData}
            pagenumber={1}
            pagesize={200}
            total={1}
            pageChange={() => {}}
            filterFetch={() => {}}
            filterClear={() => {}}
            columnsMapping={columnsMapping}
            columnsWidth={columnsWidth}
            filterAdd={() => {}}
            actions={{
              name: 'laboverview',
              edit: slotID => this.editSlot(slotID),
              delete: slotID => {}
            }}
          />

          {updatePlan && (
            <LabOverviewSlotUpdateModal
              closeModal={this.closeModal}
              plannedDate={this.state.plannedDate}
              expectedDate={this.state.expectedDate}
              slotID={slotID}
              slotName={slotName}
              updateSlot={this.props.slotEdit}
              currentYear={this.state.currentYear}
            />
          )}
        </div>
      </div>
    );
  }
}
LabOverviewComponent.defaultProps = {
  data: []
};
LabOverviewComponent.propTypes = {
  sideMenu: PropTypes.bool.isRequired,
  data: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  pageTitle: PropTypes.func.isRequired,
  labFetch: PropTypes.func.isRequired
};
export default LabOverviewComponent;
