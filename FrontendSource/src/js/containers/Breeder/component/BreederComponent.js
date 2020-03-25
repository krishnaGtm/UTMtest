import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import moment from 'moment';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import ConfirmBox from '../../../components/Confirmbox/confirmBox';

// import BC from '../../BreederOverview';
import PHTable from '../../../components/PHTable/';
// import { getDim } from '../../../helpers/helper';
import { getDim } from '../../../helpers/helper';

class Breeder extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,
      list: props.slotList,
      // filter: [],
      // activeFilter: '',
      // visibility: false,
      pagenumber: props.pagenumber,
      pagesize: props.pagesize,
      total: props.total,

      slotID: 0,
      breedingStation: props.breedingStation,
      crop: props.crop,
      testType: props.testType,
      materialState: props.materialState,
      materialType: props.materialType,

      sStation: '',
      sCrop: '',
      sTType: 1,
      sdeterminationRequired: false,
      sMState: '',
      sMType: '',
      isolated: false,
      plates: '',
      tests: '',

      currentPeriod: props.currentPeriod,
      expectedPeriod: props.expectedPeriod,
      availTests: props.availTests,
      availPlates: props.availPlates,

      errorMsg: props.errorMsg, // 'Error: allocation capacity',

      forced: props.forced,

      modeAdd: true,

      today: moment(),
      planned: null, // moment(),
      expected: moment(props.expectedDate, userContext.dateFormat) || null // eslint-disable-line
    };
    props.pageTitle();
  }

  componentDidMount() {
    this.props.fetchForm();
    this.props.resetStoreBreeder();
    this.toReset();
    // this.props.sidemenu();
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.currentPeriod !== this.props.currentPeriod) {
      this.setState({ currentPeriod: nextProps.currentPeriod });
    }
    if (nextProps.expectedPeriod !== this.props.expectedPeriod) {
      this.setState({ expectedPeriod: nextProps.expectedPeriod });
    }
    if (nextProps.expectedDate !== this.props.expectedDate) {
      const check =
        moment(nextProps.expectedDate, userContext.dateFormat) || null; // eslint-disable-line

      if (check) {
        this.setState({ expected: check });
      }
    }
    if (nextProps.availTests !== this.props.availTests) {
      this.setState({ availTests: nextProps.availTests });
    }
    if (nextProps.availPlates !== this.props.availPlates) {
      this.setState({ availPlates: nextProps.availPlates });
    }

    if (nextProps.errorMsg !== this.props.errorMsg) {
      this.setState({ errorMsg: nextProps.errorMsg });
    }

    if (nextProps.submit === true) {
      this.toReset();
      this.props.submitToFalse();
    }
    if (nextProps.forced !== this.props.forced) {
      this.setState({ forced: nextProps.forced });
    }

    if (nextProps.breedingStation.length !== this.props.breedingStation) {
      this.setState({
        breedingStation: nextProps.breedingStation,
        crop: nextProps.crop,
        testType: nextProps.testType,
        materialState: nextProps.materialState,
        materialType: nextProps.materialType
      });
    }

    if (nextProps.slotList !== this.props.slotList) {
      this.setState({
        list: nextProps.slotList
      });
    }
    if (nextProps.pagenumber !== this.props.pagenumber) {
      this.setState({
        pagenumber: nextProps.pagenumber
      });
    }
    if (nextProps.pagesize !== this.props.pagesize) {
      this.setState({
        pagesize: nextProps.pagesize
      });
    }
    if (nextProps.total !== this.props.total) {
      this.setState({
        total: nextProps.total
      });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.updateDimensions);
    this.props.clearPageData();
  }

  updateDimensions = () => {
    const dim = getDim();
    // console.log(dim);
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  };

  toReset = () => {
    // sStation: '',
    // sCrop: '',
    this.setState({
      sTType: 1,
      sdeterminationRequired: false,
      sMState: '',
      sMType: '',
      isolated: false,
      plates: '',
      tests: '',

      currentPeriod: '',
      expectedPeriod: '',
      availTests: 0,
      availPlates: 0,

      planned: null,
      expected: null
    });
  };
  fetchTableDataOnChange = (name, value) => {
    // name :: station / crop
    const { sCrop, sStation, pagesize } = this.state;

    if (name === 'crop') {
      if (sStation !== '') {
        this.props.fetchSlot(value, sStation, 1, pagesize, []);
      }
    }
    if (sCrop !== '') {
      this.props.fetchSlot(sCrop, value, 1, pagesize, []);
    }
  };

  changeSelect = e => {
    const { name, value } = e.target;
    const { sCrop, isolated, planned } = this.state; // sMType

    // console.log(name, this.props.periodName);

    switch (name) {
      case 'station':
        this.setState({ sStation: value });
        this.fetchTableDataOnChange(name, value);
        break;
      case 'crop':
        this.props.fetchMaterialType(value);
        this.props.expectedBlank();
        // this.plantTestFetch(value, sMType, isolated, planned);
        this.setState({
          sCrop: value,
          sMType: '',
          expected: null
        });
        this.fetchTableDataOnChange(name, value);
        // this.props.fetchSlot(value, 'NLEN', 1, pagesize, []);
        break;
      case 'testType': {
        // const determination = this.state.testType.filter(
        //   test => test.testTypeID == value // eslint-disable-line
        // );
        const determination = this.state.testType.find(
          test => test.testTypeID === parseInt(value) // eslint-disable-line
        );
        // console.log(typeof (value));
        this.setState({
          sTType: value,
          sdeterminationRequired: !determination.determinationRequired, // !determination[0]['determinationRequired'], // eslint-disable-line
          tests: !determination.determinationRequired // !determination[0]['determinationRequired'] // eslint-disable-line
            ? ''
            : this.state.tests
        });
        break;
      }
      case 'materialType':
        this.plantTestFetch(sCrop, value, isolated, planned);
        this.setState({ sMType: value });
        break;
      case 'materialState':
        this.setState({ sMState: value });
        break;
      case 'plates':
        if (value > -1) {
          this.setState({ plates: value });
        }
        break;
      case 'tests':
        if (value > -1) {
          this.setState({ tests: value });
        }
        break;
      default:
    }
  };

  handleIsolationChange = () => {
    const { sMType, sCrop, planned } = this.state;
    this.plantTestFetch(sCrop, sMType, !this.state.isolated, planned);
    this.setState({ isolated: !this.state.isolated });
  };

  handlePlannedDateChange = date => {
    const { sMType, sCrop, isolated } = this.state;
    this.plantTestFetch(sCrop, sMType, isolated, date);
    this.setState({ planned: date });
  };

  plantTestFetch = (crop, mType, isolated, planned) => {
    let planDate = '';
    if (planned !== null) {
      planDate = planned.format(userContext.dateFormat); // eslint-disable-line
    }

    if (planDate !== '' && crop !== '' && mType !== '') {
      // console.log(crop, mType, isolated, planDate);
      this.props.plateTest(planDate, crop, mType, isolated);
    }
  };

  handleExpectedDateChange = date => {
    this.props.period(date.format(userContext.dateFormat).toString(), 2); // eslint-disable-line
    this.setState({ expected: date });
  };

  submit = () => {
    const {
      sStation,
      sCrop,
      sTType,
      sMState,
      sMType,
      isolated,
      planned,
      expected,
      plates,
      tests
    } = this.state;

    let testValidation = false;
    if (this.state.sdeterminationRequired) {
      testValidation = true;
    } else {
      testValidation = tests !== '';
    }
    // console.log(testValidation);
    if (
      sStation !== '' &&
      sCrop !== '' &&
      sMState !== '' &&
      sMType !== '' &&
      planned !== '' &&
      expected !== '' &&
      plates !== '' &&
      testValidation
    ) {
      const obj = {
        breedingStationCode: sStation,
        cropCode: sCrop,
        testTypeID: sTType,
        materialTypeID: sMType,
        materialStateID: sMState,
        isolated,
        plannedDate: planned.format(userContext.dateFormat) || '', // eslint-disable-line
        expectedDate: expected.format(userContext.dateFormat) || '', // eslint-disable-line
        nrOfPlates: plates,
        nrOfTests: tests,
        forced: false
      };
      // console.log(obj);
      this.props.reserve(obj);
    } else {
      this.showError();
    }
    // this.toReset();
  };

  showError = () => {
    this.props.show_error({
      status: true,
      message: ['Please fill all required fields.'],
      messageType: 2,
      notificationType: 0,
      code: ''
    });
  };

  forcedSubmit = condition => {
    const {
      sStation,
      sCrop,
      sTType,
      sMState,
      sMType,
      isolated,
      planned,
      expected,
      plates,
      tests
    } = this.state;

    if (condition) {
      const obj = {
        breedingStationCode: sStation,
        cropCode: sCrop,
        testTypeID: sTType,
        materialTypeID: sMType,
        materialStateID: sMState,
        isolated,
        plannedDate: planned.format(userContext.dateFormat) || '', // eslint-disable-line
        expectedDate: expected.format(userContext.dateFormat) || '', // eslint-disable-line
        nrOfPlates: plates,
        nrOfTests: tests,
        forced: true
      };

      this.setState({ forcedSubmit: !this.state.forcedSubmit });
      this.props.reserve(obj);
      this.props.clearError();
      this.toReset();
    } else {
      // console.log('no');
      this.setState({ forcedSubmit: !this.state.forcedSubmit });
      this.props.clearError();
      // this.showError();
    }
  };

  filterFetch = () => {
    const { sCrop, sStation } = this.state;
    const { pagesize, filter } = this.props;
    this.props.fetchSlot(sCrop, sStation, 1, pagesize, filter);
  };
  filterClear = () => {
    const { sCrop, sStation } = this.state;
    const { pagesize } = this.props;
    this.props.filterClear();
    this.props.fetchSlot(sCrop, sStation, 1, pagesize, []);
  };
  pageClick = pg => {
    const { sCrop, sStation } = this.state;
    const { pagesize, filter } = this.props;
    this.props.fetchSlot(sCrop, sStation, pg, pagesize, filter);
  };

  filterClearUI = () => {
    const { filter: filterLength } = this.props;
    if (filterLength < 1) return null;
    return (
      <button className="with-i" onClick={this.filterClear}>
        <i className="icon icon-cancel" />
        Clear filters
      </button>
    );
  };

  slotEdit = id => {
    const { modeAdd, list } = this.state;
    if (!modeAdd) return null;
    const {
      slotID,
      cropCode, breedingStationCode,
      isolated,
      materialTypeCode, materialStateCode,
      plannedDate, expectedDate,
      totalPlates, totalTests
    } = list[id];

    // console.log('planned', plannedDate);
    // console.log(moment(plannedDate, userContext.dateFormat));

    this.setState({
      modeAdd: false,

      isolated,
      slotID,
      sMType: 13,
      sMState: 2,
      planned: moment(plannedDate, userContext.dateFormat),
      expected: moment(expectedDate, userContext.dateFormat),

      plates: totalPlates,
      tests: totalTests
    });
    /*
      sCrop
      s
     */
    console.log(list[id]);
  };

  editCancel = () => {
    this.setState({
      modeAdd: true,
      isolated: false,

      sMType: '',
      sMState: '',
      planned: '',
      expected: null,

      plates: '',
      tests: ''
    });
  };
  slotUpdate = () => {
    console.log('slot update acton');
  }

  slotDelete = id => {
    const { list, modeAdd, sCrop, sStation } = this.state;
    const { slotID, slotName } = list[id];
    if (!modeAdd) return null;

    if (confirm(`Are you sure to delete Slot: ${slotName}?`)) {
      this.props.slotDelete(slotID, sCrop, sStation, slotName);
    }
  }

  render() {
    const { tblWidth, tblHeight, list, modeAdd } = this.state;
    // console.log(tblHeight, 'BBB');
    const { pagenumber, pagesize, total } = this.state;
    const columns = [
      'Action',
      'cropCode',
      'breedingStationCode',
      'slotName',
      'periodName',
      'materialStateCode',
      'materialTypeCode',
      'totalPlates',
      'totalTests',
      'availablePlates',
      'availableTests',
      'statusName',
    ];
    const columnsMapping = {
      cropCode: {
        name: 'Crop',
        filter: true,
        fixed: true
      },
      breedingStationCode: {
        name: 'Br.Station',
        filter: true,
        fixed: true
      },
      slotName: {
        name: 'Slot Name',
        filter: true,
        fixed: true
      },
      periodName: {
        name: 'Period Name',
        filter: true,
        fixed: true
      },
      materialStateCode: {
        name: 'Material State',
        filter: true,
        fixed: true
      },
      materialTypeCode: {
        name: 'Material Type',
        filter: true,
        fixed: true
      },
      totalPlates: {
        name: 'Total Plates',
        filter: true,
        fixed: true
      },
      totalTests: {
        name: 'Total Tests',
        filter: true,
        fixed: true
      },
      availablePlates: {
        name: 'Available Plates',
        filter: true,
        fixed: true
      },
      availableTests: {
        name: 'Available Tests',
        filter: true,
        fixed: true
      },
      statusName: {
        name: 'Status',
        filter: true,
        fixed: true
      },
      Action: {
        name: 'Action',
        filter: false,
        fixed: false
      }
    };
    const columnsWidth = {
      cropCode: 80,
      breedingStationCode: 100,
      slotName: 160,
      periodName: 240,
      materialStateCode: 120,
      materialTypeCode: 120,
      availablePlates: 140,
      availableTests: 130,
      totalPlates: 120,
      totalTests: 120,
      statusName: 120,
      Action: 70
    };

    const { today, planned, currentPeriod, expectedPeriod } = this.state;
    const { plates, tests, forced, availPlates, availTests } = this.state;
    let { expected } = this.state;
    const {
      breedingStation,
      crop,
      materialState,
      materialType,
      testType
    } = this.state;
    const { sStation, sCrop, sTType, sMState, sMType } = this.state;
    const { isolated } = this.state;

    let notallow = true;
    if (sMType !== '' && sCrop !== '' && planned !== null) {
      notallow = false;
    }

    const periodName = this.props.periodName.length
      ? this.props.periodName[0].periodName
      : '';

    if (expected) {
      if (expected.format('L') === 'Invalid date') {
        expected = null;
      }
    }

    const subHeight = 355 - 20;
    const calcHeight = tblHeight - subHeight;
    const nHeight = calcHeight;

    return (
      <div className="breeder">
        {forced && (
          <ConfirmBox message={this.state.errorMsg} click={this.forcedSubmit} />
        )}
        <section className="page-action">
          <div className="left">
            {this.filterClearUI()}
            <div className="form-e">
              <label className="full">Current period : {periodName}</label>
            </div>
          </div>
        </section>

        <div className="container">
          <div className="row">
            <div className="form-e">
              <label htmlFor="crop">Crop *</label> {/* eslint-disable-line */}
              <select name="crop" onChange={this.changeSelect} value={sCrop} disabled={!modeAdd}>
                <option value="">Select Crop</option>
                {crop.map(cropList => (
                  <option key={cropList.cropCode} value={cropList.cropCode}>
                    {cropList.cropCode} - {cropList.cropName}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-e">
              <label htmlFor="station">Breeding Station *</label> {/* eslint-disable-line */}
              <select
                name="station"
                onChange={this.changeSelect}
                value={sStation}
                disabled={!modeAdd}
              >
                <option value="">Select Station</option>
                {breedingStation.map(d => (
                  <option
                    key={d.breedingStationCode}
                    value={d.breedingStationCode}
                  >
                    {d.breedingStationCode}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-e">
              <label htmlFor="testType">Test Type</label> {/* eslint-disable-line */}
              <select
                name="testType"
                onChange={this.changeSelect}
                value={sTType}
                disabled={!modeAdd}
              >
                {testType.map(testList => (
                  <option key={testList.testTypeID} value={testList.testTypeID}>
                    {testList.testTypeName}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-e">
              <label>&nbsp;</label> {/* eslint-disable-line */}
              <div className="checkBox">
                <input
                  checked={isolated || false}
                  type="checkbox"
                  id="isolationBreeder"
                  onChange={this.handleIsolationChange}
                  disabled={!modeAdd}
                />
                <label htmlFor="isolationBreeder">Isolated</label> {/* eslint-disable-line */}
              </div>
            </div>
          </div>
          <div className="row">
            <div className="form-e">
              <label htmlFor="materialType">Material Type *</label> {/* eslint-disable-line */}
              <select
                name="materialType"
                onChange={this.changeSelect}
                value={sMType}
                disabled={!modeAdd}
              >
                <option value="">Select Material Type</option>
                {materialType.map(materialTypeList => {
                  const {
                    materialTypeID,
                    materialTypeCode,
                    materialTypeDescription
                  } = materialTypeList;
                  return (
                    <option key={materialTypeID} value={materialTypeID}>
                      {materialTypeCode} - {materialTypeDescription}
                    </option>
                  );
                })}
              </select>
            </div>
            <div className="form-e">
              <label htmlFor="materialState">Material State *</label> {/* eslint-disable-line */}
              <select
                name="materialState"
                onChange={this.changeSelect}
                value={sMState}
                disabled={!modeAdd}
              >
                <option value="">Select Material State</option>
                {materialState.map(materialStateList => {
                  const {
                    materialStateID,
                    materialStateCode,
                    materialStateDescription
                  } = materialStateList;
                  return (
                    <option key={materialStateID} value={materialStateID}>
                      ({materialStateCode}) {materialStateDescription}
                    </option>
                  );
                })}
              </select>
            </div>
            <div className="form-e">
              <label htmlFor="materialState"> {/* eslint-disable-line */}
                Planned Date * {currentPeriod ? ` (${currentPeriod})` : ''}
              </label>
              <DatePicker
                selected={planned || null}
                minDate={today}
                onChange={this.handlePlannedDateChange}
                dateFormat={userContext.dateFormat} // eslint-disable-line
                showWeekNumbers
                locale="en-gb"
              />
            </div>
            <div className="form-e">
              <label htmlFor="materialState"> {/* eslint-disable-line */}
                Expected Date * {expectedPeriod ? ` (${expectedPeriod})` : ''}
              </label>
              <DatePicker
                selected={expected || null}
                minDate={planned || today}
                disabled={notallow}
                onChange={this.handleExpectedDateChange}
                dateFormat={userContext.dateFormat} // eslint-disable-line
                showWeekNumbers
                locale="en-gb"
              />
            </div>
          </div>

          <div className="row">
            <div className="form-e">
              <label htmlFor="materialState"> {/* eslint-disable-line */}
                Number of plates * {availPlates ? `(${availPlates})` : ''}
              </label>
              <input
                type="number"
                name="plates"
                value={plates}
                onChange={this.changeSelect}
                disabled={!modeAdd}
              />
            </div>
            <div className="form-e">
              <label htmlFor="materialState"> {/* eslint-disable-line */}
                Number of tests * {availTests ? `(${availTests})` : ''}
              </label>
              <input
                type="number"
                name="tests"
                value={tests}
                disabled={this.state.sdeterminationRequired || !modeAdd}
                onChange={this.changeSelect}
              />
            </div>
            <div className="form-e">
              <label>&nbsp;</label>
              {modeAdd === true && <button onClick={this.submit}>Reserve Capacity</button>}
              {modeAdd === false && (
                <Fragment>
                  <button onClick={this.slotUpdate}>Update</button>
                  &nbsp;&nbsp;
                  <button onClick={this.editCancel}>Cancel</button>
                </Fragment>
              )}
            </div>
            <div />
          </div>
        </div>

        <div className="container">
          <PHTable
            fileSource
            sideMenu={this.props.sideMenu}
            filter={this.props.filter}
            tblWidth={tblWidth}
            tblHeight={nHeight}
            columns={columns}
            data={list}
            pagenumber={pagenumber}
            pagesize={pagesize}
            total={total}
            pageChange={this.pageClick}
            filterFetch={this.filterFetch}
            filterClear={this.filterClear}
            columnsMapping={columnsMapping}
            columnsWidth={columnsWidth}
            filterAdd={this.props.filterAdd}
            actions={{
              name: 'breeder',
              edit: slotID => this.slotEdit(slotID),
              delete: slotID => this.slotDelete(slotID)
            }}
          />
        </div>
      </div>
    );
  }
}

Breeder.defaultProps = {
  slotList: [],
  filter: [],

  breedingStation: [],
  crop: [],
  testType: [],
  materialState: [],
  materialType: [],
  periodName: [],

  currentPeriod: '',
  expectedPeriod: '',
  availTests: 0,
  availPlates: 0,

  errorMsg: '',
  submit: false,
  forced: false,
  expectedDate: null
};
Breeder.propTypes = {
  slotEdit: PropTypes.func.isRequired,
  slotDelete: PropTypes.func.isRequired,

  clearPageData: PropTypes.func.isRequired,
  filterClear: PropTypes.func.isRequired,
  fetchSlot: PropTypes.func.isRequired,
  filter: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  filterAdd: PropTypes.func.isRequired,
  pagenumber: PropTypes.number.isRequired,
  pagesize: PropTypes.number.isRequired,
  total: PropTypes.number.isRequired,
  slotList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  sideMenu: PropTypes.bool.isRequired,

  pageTitle: PropTypes.func.isRequired,
  // sidemenu: PropTypes.func.isRequired,
  reserve: PropTypes.func.isRequired,
  fetchForm: PropTypes.func.isRequired,
  plateTest: PropTypes.func.isRequired,
  show_error: PropTypes.func.isRequired,
  submitToFalse: PropTypes.func.isRequired,

  resetStoreBreeder: PropTypes.func.isRequired,
  expectedBlank: PropTypes.func.isRequired,
  fetchMaterialType: PropTypes.func.isRequired,
  clearError: PropTypes.func.isRequired,

  period: PropTypes.func.isRequired,

  breedingStation: PropTypes.array, // eslint-disable-line
  crop: PropTypes.array, // eslint-disable-line
  testType: PropTypes.array, // eslint-disable-line
  materialState: PropTypes.array, // eslint-disable-line
  materialType: PropTypes.array, // eslint-disable-line
  periodName: PropTypes.array, // eslint-disable-line

  currentPeriod: PropTypes.string,
  expectedPeriod: PropTypes.string,
  availTests: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  availPlates: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),

  errorMsg: PropTypes.string,
  submit: PropTypes.bool,
  forced: PropTypes.bool,
  expectedDate: PropTypes.oneOfType([PropTypes.object, PropTypes.string])
};
export default Breeder;
