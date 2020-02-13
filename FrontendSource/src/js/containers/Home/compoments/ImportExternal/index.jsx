import React, { Component } from 'react';
import moment from 'moment';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import DateInput from '../../../../components/DateInput';
import Dropdown from '../../../../components/Combobox/Combobox';
import ImportFile from './importFile';

// import '../ImportFileModal/modal.css';
import './modal.scss';

class ImportExternal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      todayDate: moment(),
      startDate: moment(),
      expectedDate: moment().add(14, 'days'),
      isolationStatus: false,
      materialTypeID: 0,
      materialStateID: 0,
      containerTypeID: 0,
      testTypeID: 1,
      fileName: '', // for name
      cropSelected: '',
      breedingStationSelected: ''
    };
  }
  handleAllChange = e => {
    const { target } = e;
    const { name, value } = target;
    // console.log(name, value);
    this.setState({
      [name]: value
    });
  };

  handleDateChange = date => {
    this.setState({
      startDate: date,
      expectedDate: moment(date).add(14, 'days')
    });
  };
  handleExpectedDateChange = date => {
    this.setState({
      expectedDate: date
    });
  };
  handleIsolationChange = () => {
    this.setState({
      isolationStatus: !this.state.isolationStatus
    });
  };

  handleContainerTypeChange = e => {
    this.setState({
      containerTypeID: e.target.value * 1
    });
  };
  handleMaterialStateChange = e => {
    this.setState({
      materialStateID: e.target.value * 1
    });
  };

  handleMaterialTypeChange = e => {
    this.setState({
      materialTypeID: e.target.value * 1
    });
  };

  handleTestTypeChange = e => {
    this.setState({
      testTypeID: e.target.value * 1
    });
  };

  importExternalData = () => {
    // const {
    //   testTypeID, materialStateID, materialTypeID, containerTypeID, startDate,
      // expectedDate, isolationStatus, fileName, cropSelected: cropCode,
      // breedingStationSelected: brStationCode } = this.state;
      //
    // console.log(testTypeID, materialStateID, materialTypeID, containerTypeID, startDate, expectedDate, isolationStatus, fileName, cropCode, brStationCode);
  };

  render() {
    const { visibility, toggleVisibility, materialTypeList, materialStateList,
      containerTypeList, testTypeList, crops, breedingStation } = this.props;
    const { fileName, isolationStatus, materialTypeID, materialStateID,
      containerTypeID, testTypeID, startDate, expectedDate, cropSelected,
      breedingStationSelected } = this.state;

    const testTypelistWithTwoGB = testTypeList.filter(t => {
      const { testTypeCode } = t;
      return testTypeCode !== '3GBProject' && testTypeCode !== 'GMAS'
        ? t
        : null;
    });

    return (
      <div className="import-modal"style={{ display: `${visibility ? '' : 'none'}` }}>
        <div className="content">
          <div className="title">
            <span
              className="close"
              onClick={toggleVisibility}
              tabIndex="0"
              onKeyDown={() => {}}
              role="button"
            >
              &times;
            </span>
            <span>Import External File</span>
          </div>
          <div className="data-section">
            <div className="body">
              <div>
                <label htmlFor="cropSelected">
                  Crops
                  <select name="cropSelected" onChange={this.handleAllChange}>
                    <option value="">Select</option>
                    {crops.map(c => (
                      <option value={c} key={c}>
                        {c}
                      </option>
                    ))}
                  </select>
                </label>
              </div>
              <div>
                <label htmlFor="breedingStationSelected">
                  Br.Station
                  <select
                    name="breedingStationSelected"
                    onChange={this.handleAllChange}
                  >
                    <option value="">Select</option>
                    {breedingStation.map(b => (
                      <option
                        value={b.breedingStationCode}
                        key={b.breedingStationCode}
                      >
                        {b.breedingStationCode}
                      </option>
                    ))}
                  </select>
                </label>
              </div>
              <Dropdown
                label="Test type"
                options={testTypelistWithTwoGB}
                value={this.state.testTypeID}
                change={this.handleTestTypeChange}
                listName="testTypeName"
                listCode="testTypeID"
              />
              <DateInput
                label="Planned Week"
                todayDate={this.state.todayDate}
                selected={this.state.startDate}
                change={this.handleDateChange}
              />
              <DateInput
                label="Expected Week"
                todayDate={this.state.startDate}
                selected={this.state.expectedDate}
                change={this.handleExpectedDateChange}
              />
              <Dropdown
                label="Material Type"
                options={materialTypeList}
                value={this.state.materialTypeID}
                change={this.handleMaterialTypeChange}
              />
              <Dropdown
                label="Material State"
                options={materialStateList}
                value={this.state.materialStateID}
                change={this.handleMaterialStateChange}
              />
              <Dropdown
                label="Container Type"
                options={containerTypeList}
                value={this.state.containerTypeID}
                change={this.handleContainerTypeChange}
              />
              <div className="markContainer">
                <div className="marker">
                  <label>&nbsp;</label>
                  <input
                    type="checkbox"
                    id="isolationModal"
                    checked={this.state.isolationStatus}
                    onChange={this.handleIsolationChange}
                  />
                  <label htmlFor="isolationModal">Already Isolated</label> {/*eslint-disable-line*/}
                </div>
              </div>
            </div>

            <div className="body2" />
            <div className="footer">
              <ImportFile
                cropSelected={cropSelected}
                breedingSelected={breedingStationSelected}
                isolationStatus={isolationStatus}
                closeModal={toggleVisibility}
                materialTypeID={materialTypeID}
                materialStateID={materialStateID}
                containerTypeID={containerTypeID}
                testTypeID={testTypeID}
                selectedDate={startDate}
                expectedDate={expectedDate}
                changeTabIndex={this.props.changeTabIndex}
                fileName={fileName}
              />
              {/* <button onClick={this.importExternalData}>
                Import data from External
              </button> */}
              <span style={{ fontSize: '0.9em', paddingTop: '10px' }}>
                Note: Selecting file will automatically upload file with data
                filled in above form.
              </span>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

ImportExternal.propTypes = {
  // threegbList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // breedingStation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // fetchProjectList: PropTypes.func.isRequired,
  visibility: PropTypes.bool.isRequired,
  toggleVisibility: PropTypes.func.isRequired,
  changeTabIndex: PropTypes.func.isRequired,
  materialTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  crops: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  breedingStation: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  materialStateList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  containerTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  testTypeList: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};
const mapStateToProps = state => ({
  // isLoggedIn: state.phenome.isLoggedIn,
  crops: state.user.crops,
  breedingStation: state.breedingStation.station
  // threegbList: state.assignMarker.threegb
});
export default connect(mapStateToProps, null)(ImportExternal);
