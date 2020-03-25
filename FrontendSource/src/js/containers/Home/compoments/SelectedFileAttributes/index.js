import React, { Component } from 'react';
import moment from 'moment';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import DateInput from '../../../../components/DateInput';
import Dropdown from '../../../../components/Combobox/Combobox';
import './selected-file.scss';

class SelectedFileAttributes extends Component {
  constructor(props) {
    super(props);
    const selectedMaterialType = props.materialTypeList.find(item => item.selected);
    const selectedMaterialState = props.materialStateList.find(item => item.selected);
    const selectedContainerType = props.containerTypeList.find(item => item.selected);

    this.state = {
      cumulate: props.cumulate,
      testEditMode: false,
      todayDate: moment(),
      plannedDate: props.plannedDate,
      expectedDate: props.expectedDate,
      isolationStatus: props.isolationStatus,
      materialTypeID: selectedMaterialType ? selectedMaterialType.materialTypeID : 0,
      materialStateID: selectedMaterialState ? selectedMaterialState.materialStateID : 0,
      containerTypeID: selectedContainerType ? selectedContainerType.containerTypeID : 0,
      testTypeID: props.testTypeID,
      slotID: props.slotID
    };
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.cumulate !== this.props.cumulate) {
      // console.log('cumulate different value');
      this.setState({ cumulate: nextProps.cumulate });
    }
    if (nextProps.isolationStatus !== this.props.isolationStatus) {
      this.setState({ isolationStatus: nextProps.isolationStatus });
    }
    if (nextProps.slotID !== this.props.slotID) {
      // console.log(nextProps.slotID, this.props.slotID);
      this.setState({ slotID: nextProps.slotID });
    }
    if (nextProps.plannedDate !== this.props.plannedDate) {
      this.setState({ plannedDate: nextProps.plannedDate });
    }
    if (nextProps.expectedDate !== this.props.expectedDate) {
      this.setState({ expectedDate: nextProps.expectedDate });
    }
    if (nextProps.testTypeID !== this.props.testTypeID) {
      this.setState({ testTypeID: nextProps.testTypeID });
    }
    const selectedMaterialType = nextProps.materialTypeList.find(item => item.selected);
    const selectedMaterialState = nextProps.materialStateList.find(item => item.selected);
    const selectedContainerType = nextProps.containerTypeList.find(item => item.selected);
    this.setState({
      materialTypeID: selectedMaterialType
        ? selectedMaterialType.materialTypeID
        : 0,
      materialStateID: selectedMaterialState
        ? selectedMaterialState.materialStateID
        : 0,
      containerTypeID: selectedContainerType
        ? selectedContainerType.containerTypeID
        : 0
    });
    if (nextProps.updateAttributesFailed) {
      this.resetAttributesToOriginalState();
      this.props.dispatch({ type: 'RESET_UPDATE_ATTRIBUTES_FAILURE' });
    }
    if (nextProps.testID !== this.props.testID) {
      this.setState({ testEditMode: false });
    }
  }

  resetAttributesToOriginalState() {
    this.setState({
      plannedDate: this.props.plannedDate,
      expectedDate: this.props.expectedDate,
      isolationStatus: this.props.isolationStatus,
      materialTypeID: null,
      materialStateID: null,
      containerTypeID: null,
      testTypeID: this.props.testTypeID,
      slotID: this.props.slotID
    });
  }

  handleEditOrCancelButton = () => {
    if (this.state.testEditMode) {
      this.resetAttributesToOriginalState();
    } else {
      this.setState({
        materialTypeID: this.props.materialTypeList.find(item => item.selected)
          .materialTypeID,
        materialStateID: this.props.materialStateList.find(item => item.selected).materialStateID,
        containerTypeID: this.props.containerTypeList.find(item => item.selected).containerTypeID
      });
    }
    this.setState({
      testEditMode: !this.state.testEditMode
    });
  };

  resetSelectedTestAttributes = () => {
    // console.log(selectedContainerType, selectedMaterialState, selectedMaterialType);
    this.setState({
      plannedDate: this.props.plannedDate,
      expectedDate: this.props.expectedDate,
      isolationStatus: this.props.isolationStatus,
      materialTypeID: this.props.materialTypeList.find(item => item.selected)
        .materialTypeID,
      materialStateID: this.props.materialStateList.find(item => item.selected)
        .materialStateID,
      containerTypeID: this.props.containerTypeList.find(item => item.selected)
        .containerTypeID,
      testTypeID: this.props.testTypeID,
      cumulate: this.props.cumulate
    });
  };

  updateSelectedTestAttributes = () => {
    if (
      this.state.materialTypeID === 0 ||
      this.state.materialStateID === 0 ||
      this.state.containerTypeID === 0 ||
      this.state.materialTypeID === null ||
      this.state.materialStateID === null ||
      this.state.containerTypeID === null
    ) {
      this.props.showError({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please select Material Type, Material State and Container Type.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
    } else {
      const currentTestType = this.props.testTypeList.find(testType => testType.testTypeID === this.state.testTypeID);
      const attributes = {
        testID: this.props.testID,
        plannedDate: this.state.plannedDate,
        expectedDate: this.state.expectedDate,
        materialTypeID: this.state.materialTypeID,
        containerTypeID: this.state.containerTypeID * 1,
        isolated: this.state.isolationStatus,
        testTypeID: this.state.testTypeID,
        materialStateID: this.state.materialStateID * 1,
        cropCode: this.props.cropCode,
        breeding: this.props.breeding,
        determinationRequired: currentTestType.determinationRequired,
        slotID: this.state.slotID,
        cumulate: this.state.cumulate
      };
      // console.log(attributes);
      this.props.updateTestAttributes(attributes);
      this.setState({
        testEditMode: false
      });
    }
  };

  handleDateChange = date => {
    const expDate = moment(date, userContext.dateFormat).add(14, 'days'); // eslint-disable-line
    this.setState({
      plannedDate: date.format(userContext.dateFormat),  // eslint-disable-line
      expectedDate: expDate.format(userContext.dateFormat)  // eslint-disable-line
    });
  };

  handleExpectedDateChange = date => {
    this.setState({ expectedDate: date.format(userContext.dateFormat) }); // eslint-disable-line
  };

  handleIsolationChange = () => {
    this.setState({ isolationStatus: !this.state.isolationStatus });
  };
  handleCumulate = () => {
    this.setState({ cumulate: !this.state.cumulate });
  };

  handleContainerTypeChange = e => {
    this.setState({ containerTypeID: e.target.value * 1 });
  };

  handleMaterialStateChange = e => {
    this.setState({ materialStateID: e.target.value * 1 });
    // this.fetchSlot(this.props.testID, e.target.value, this.state.materialTypeID);
  };

  handleMaterialTypeChange = e => {
    this.setState({ materialTypeID: e.target.value * 1 });
    // this.fetchSlot(this.props.testID, this.state.materialStateID, e.target.value, this.state.isolationStatus, this.state.date);
  };

  // fetchSlot = (testID, materialStateID, materialTypeID, isolation, date) => {
  //   // console.log(testID, materialStateID, materialTypeID, date);
  // };

  handleTestTypeChange = e => {
    this.setState({ testTypeID: e.target.value * 1 });
  };

  render() {
    const {
      visibility,
      materialTypeList,
      materialStateList,
      containerTypeList,
      testTypeList,
      testTypeID
    } = this.props;
    const { slotID } = this.state;
    const threeGBstatus = testTypeID === 4 || testTypeID === 5;
    // console.log('threeGBstatus', threeGBstatus, testTypeID, ' - ', slotID);
    return (
      <div
        className="imported-files-attributes"
        style={{
          display: `${visibility ? 'block' : 'none'}`
        }}
      >
        <div className="trow">
          <div className="tcell">
            <Dropdown
              disabled={!this.state.testEditMode || testTypeID === 4}
              label="Test type"
              options={testTypeList}
              value={this.state.testTypeID}
              change={this.handleTestTypeChange}
            />
          </div>
          {testTypeID === 4 && (
            <div className="tcell">
              <div>
                <label>Project List</label>
                <select defaultValue={this.props.testID} disabled>
                  {this.props.fileList.map(f => (
                    <option key={`${f.testID}-p`}>{f.fileTitle}</option>
                  ))};
                </select>
              </div>
              {/* <Dropdown
                label="Project List"
                options={this.props.fileList || []}
                value={this.props.testID}
                change={() => {}}
                disabled={testTypeID !== ''}
              /> */}
            </div>
          )}
          {!threeGBstatus && (
            <div className="tcell">
              <Dropdown
                disabled={!this.state.testEditMode}
                label="Material Type"
                options={materialTypeList}
                value={this.state.materialTypeID}
                change={this.handleMaterialTypeChange}
              />
            </div>
          )}
          {!threeGBstatus && (
            <div className="tcell">
              <Dropdown
                disabled={!this.state.testEditMode}
                label="Material State"
                options={materialStateList}
                value={this.state.materialStateID}
                change={this.handleMaterialStateChange}
              />
            </div>
          )}
          {/*
          <div className="tcell">
            <Dropdown
              disabled={!this.state.testEditMode}
              label="Slot"
              options={slotList}
              value={this.state.slotID}
              change={this.handleSlotChange}
            />
          </div>
          */}
          <div className="tcell">
            <Dropdown
              disabled={!this.state.testEditMode}
              label="Container Type"
              options={containerTypeList}
              value={this.state.containerTypeID}
              change={this.handleContainerTypeChange}
            />
          </div>
        </div>
        {!threeGBstatus && (
          <div className="trow">
            <div className="tcell">
              <DateInput
                disabled={!this.state.testEditMode}
                label="Planned Week"
                todayDate={this.state.todayDate}
                selected={moment(this.state.plannedDate, [
                  moment.HTML5_FMT.DATETIME_LOCAL_SECONDS,
                  'DD/MM/YYYY'
                ])}
                change={this.handleDateChange}
              />
            </div>
            <div className="tcell">
              <DateInput
                disabled={!this.state.testEditMode}
                label="Expected Week"
                todayDate={moment(this.state.plannedDate, [
                  moment.HTML5_FMT.DATETIME_LOCAL_SECONDS,
                  'DD/MM/YYYY'
                ])}
                selected={moment(this.state.expectedDate, [
                  moment.HTML5_FMT.DATETIME_LOCAL_SECONDS,
                  'DD/MM/YYYY'
                ])}
                change={this.handleExpectedDateChange}
              />
            </div>
            <div className="tcell">
              <div className="markContainer">
                <label>&nbsp;</label>  {/*eslint-disable-line*/}
                <div
                  className={
                    this.state.testEditMode ? 'marker' : 'marker disabled'
                  }
                >
                  <input
                    type="checkbox"
                    id="isolationHome"
                    disabled={!this.state.testEditMode}
                    checked={this.state.isolationStatus || false}
                    onChange={this.handleIsolationChange}
                  />
                  <label htmlFor="isolationHome">Already Isolated</label>  {/*eslint-disable-line*/}
                </div>
              </div>
            </div>
            <div className="tcell">
              <div className="markContainer">
                <label>&nbsp;</label>  {/*eslint-disable-line*/}
                <div
                  className={
                    this.state.testEditMode ? 'marker' : 'marker disabled'
                  }
                >
                  <input
                    type="checkbox"
                    id="cumulateHome"
                    disabled={!this.state.testEditMode}
                    checked={this.state.cumulate}
                    onChange={this.handleCumulate}
                  />
                  <label htmlFor="cumulateHome">Cumulate</label>  {/*eslint-disable-line*/}
                </div>
              </div>
            </div>
          </div>
        )}
        {this.props.statusCode < 400 &&
          (this.state.slotID === null || this.state.slotID === 0 || !this.state.slotID) && (
            <div className="imported-files-actions">
              {!threeGBstatus && (
                <button
                  onClick={this.handleEditOrCancelButton}
                  className="imported-files-actions-button"
                  title={this.state.testEditMode ? 'Cancel' : 'Edit'}
                >
                  {this.state.testEditMode ? (
                    <i className="icon icon-cancel" />
                  ) : (
                    <i className="icon icon-pencil" />
                  )}
                  {this.state.testEditMode ? 'Cancel' : 'Edit'}
                </button>
              )}
              {this.state.testEditMode && (
                <button
                  onClick={this.resetSelectedTestAttributes}
                  disabled={!this.state.testEditMode}
                  className="imported-files-actions-button"
                  title="Reset form"
                >
                  <i className="icon icon-ccw" />Reset
                </button>
              )}
              {this.state.testEditMode && (
                <button
                  onClick={this.updateSelectedTestAttributes}
                  disabled={!this.state.testEditMode}
                  className="imported-files-actions-button"
                  title="Save"
                >
                  <i className="icon icon-floppy" />Save
                </button>
              )}
            </div>
          )}
      </div>
    );
  }
}
const mapStateToProps = state => ({
  updateAttributesFailed:
    state.assignMarker.file.selected.updateAttributesFailed
});
SelectedFileAttributes.defaultProps = {
  fileList: [],
  materialTypeList: [],
  materialStateList: [],
  containerTypeList: [],
  testTypeList: [],
  // slotList: [],
  updateAttributesFailed: null,
  testTypeID: null,
  isolationStatus: null,
  cropCode: null,
  slotID: null,
  breeding: '',
  expectedDate: ''
};
SelectedFileAttributes.propTypes = {
  cumulate: PropTypes.bool.isRequired,
  breeding: PropTypes.string,
  fileList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  materialTypeList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  materialStateList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  containerTypeList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  testTypeList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // slotList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  plannedDate: PropTypes.string.isRequired,
  expectedDate: PropTypes.string,
  cropCode: PropTypes.string,
  isolationStatus: PropTypes.bool,
  visibility: PropTypes.bool.isRequired,
  updateAttributesFailed: PropTypes.bool,
  testTypeID: PropTypes.number,
  statusCode: PropTypes.number.isRequired,
  testID: PropTypes.number.isRequired,
  // slotID: PropTypes.number,
  dispatch: PropTypes.func.isRequired,
  showError: PropTypes.func.isRequired,
  updateTestAttributes: PropTypes.func.isRequired
};
export default connect(mapStateToProps)(SelectedFileAttributes);
