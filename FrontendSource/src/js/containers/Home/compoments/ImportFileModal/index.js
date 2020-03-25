/**
 * Created by sushanta on 2/27/18.
 */
import React from 'react';
import moment from 'moment';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImportFile from './ImportFile';
import DateInput from '../../../../components/DateInput';
import Dropdown from '../../../../components/Combobox/Combobox';
// import './modal.css';
import '../ImportExternal/modal.scss';

class ImportFileModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      todayDate: moment(),
      startDate: moment(),
      // expectedDate: null,
      expectedDate: moment().add(14, 'days'),
      isolationStatus: false,
      materialTypeID: 0,
      materialStateID: 0,
      containerTypeID: 0,
      testTypeID: 1,
      // cropSelected: '',
      // breedingStationSelected: '',
      // threeGBTaskID: '', // project selected
      // threegbList: props.threegbList,
      fileName: '' // for name
    };
    // moment("06/09/2018", userContext.dateFormat).add(14, 'days'),
  }
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
  render() {
    const {
      visibility,
      toggleVisibility,
      materialTypeList,
      materialStateList,
      containerTypeList,
      testTypeList
    } = this.props;
    const { fileName } = this.state;

    const testTypelistWithTwoGB = testTypeList.filter(t => {
      const { testTypeCode } = t;
      return testTypeCode !== '3GBProject' && testTypeCode !== 'GMAS'
        ? t
        : null;
    });
    // console.log(testTypelistWithTwoGB);
    // const projectDisable = testTypeID === 4 || testTypeID === 5;;
    return (
      <div
        className="import-modal"
        style={{ display: `${visibility ? '' : 'none'}` }}
      >
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
            <span>Import New File</span>
          </div>
          <div className="data-section">
            <div className="body">
              <Dropdown
                label="Test type"
                options={testTypelistWithTwoGB}
                value={this.state.testTypeID}
                change={this.handleTestTypeChange}
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
            <div className="footer">
              <ImportFile
                isolationStatus={this.state.isolationStatus}
                closeModal={toggleVisibility}
                materialTypeID={this.state.materialTypeID}
                materialStateID={this.state.materialStateID}
                containerTypeID={this.state.containerTypeID}

                testTypeID={this.state.testTypeID}

                selectedDate={this.state.startDate}
                expectedDate={this.state.expectedDate}
                changeTabIndex={this.props.changeTabIndex}

                fileName={fileName}
              />
              <br />
              <span style={{ fontSize: '0.9em' }}>
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

// ImportFileModal.defaultProps = {
//   threegbList: [],
//   crops: [],
//   breedingStation: []
// };
ImportFileModal.propTypes = {
  // threegbList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // breedingStation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // fetchProjectList: PropTypes.func.isRequired,
  visibility: PropTypes.bool.isRequired,
  toggleVisibility: PropTypes.func.isRequired,
  changeTabIndex: PropTypes.func.isRequired,
  materialTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  materialStateList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  containerTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  testTypeList: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};
const mapStateToProps = state => ({
  crops: state.user.crops,
  breedingStation: state.breedingStation.station,
  threegbList: state.assignMarker.threegb
});
// importPhenome: data => {
//   dispatch(importPhenomeAction(data));
// },
// const mapDispatchToProps = dispatch => ({
//   fetchProjectList: (crop, breeding) => {
//     // console.log(crop, breeding);
//     dispatch({
//       type: 'THREEGB_PROJECTLIST_FETCH',
//       crop,
//       breeding
//     });
//   }
// });

export default connect(mapStateToProps, null)(ImportFileModal);
