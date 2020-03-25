/**
 * Created by sushanta on 2/27/18.
 */
import React, { Fragment } from 'react';
import moment from 'moment';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import { runWithAdal } from 'react-adal';
import { adalConfig, authContext } from '../auth';

import DateInput from '../../../../components/DateInput';
import Dropdown from '../../../../components/Combobox/Combobox';
import Login from './Login';
import Treeview from './Treeview';
import ConfirmBox from '../../../../components/Confirmbox/confirmBox';
import '../ImportExternal/modal.scss';
import { phenomeLogin, importPhenomeAction } from '../../actions/phenome';

class ImportPhenome extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      todayDate: moment(),
      startDate: moment(),
      expectedDate: moment().add(14, 'days'),
      isolationStatus: false,
      cumulateStatus: false,
      materialTypeID: 0,
      materialStateID: 0,
      containerTypeID: 0,
      testTypeID: 1,
      testTypeCode: 'MT',

      objectID: '',
      objectType: '',
      researchGroupID: '',
      cropID: '',
      folderObjectType: '',
      researchGroupObjectType: '',

      fileName: '',
      cropSelected: '',
      breedingStationSelected: '',
      threeGBTaskID: '', // project selected
      threegbList: props.threegbList,
      importLevel: 'PLT',
      importPhemoneExisting: props.importPhemoneExisting,

      warningFlag: props.warningFlag,
      warningMessage: props.warningMessage
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.importPhemoneExisting !== this.state.importPhemoneExisting) {
      this.setState({
        importPhemoneExisting: nextProps.importPhemoneExisting
      });
    }
    if (nextProps.threegbList) {
      this.setState({
        threegbList: nextProps.threegbList
      });
    }
    if (nextProps.warningFlag !== this.props.warningFlag) {
      this.setState({
        warningFlag: nextProps.warningFlag,
        warningMessage: nextProps.warningMessage
      });
      // if (nextProps.warningFlag) {
      //   console.log('warningFlag true : toggleVisiblility()');
      //   this.props.toggleVisibility();
      // }
    }
  }

  getToken = () => sessionStorage.getItem('adal.idtoken');

  changeFetch = (name, value) => {
    if (name === 'threeGBTaskID') {
      const { threegbList, testTypeID } = this.state;
      const projectDisplay = testTypeID === 4 || testTypeID === 5;
      // console.log(this.state.threegbList(d => d.threeGBTaskID === value));
      if (projectDisplay) {
        let threegbFilename = '';
        threegbList.map(d => {
          // console.log(d, value);
          if (d.threeGBTaskID === value * 1) {
            // console.log(d.threeGBProjectcode);
            threegbFilename = d.threeGBProjectcode;
          }
          return null;
        });
        this.setState({
          fileName: threegbFilename
        });
      }
      // console.log(threegbList);
    }

    const { cropSelected, breedingStationSelected, testTypeCode } = this.state;
    const { fetchProjectList } = this.props;
    if (name === 'cropSelected') {
      if (breedingStationSelected !== '') {
        fetchProjectList(value, breedingStationSelected, testTypeCode);
      }
      this.setState({ threeGBTaskID: '', fileName: '' });
    }
    if (name === 'breedingStationSelected') {
      if (cropSelected !== '' && value !== '') {
        fetchProjectList(cropSelected, value, testTypeCode);
      }
      this.setState({ threeGBTaskID: '', fileName: '' });
    }
  };

  handleDateChange = date => {
    this.setState({
      startDate: date,
      expectedDate: moment(date).add(14, 'days')
    });
  };
  handleExpectedDateChange = date => {
    this.setState({ expectedDate: date });
  };
  handleTypeAndState = e => {
    const { name, value } = e.target;
    this.setState({ [name]: value * 1 });
  };

  handleTestTypeChange = e => {
    const { target } = e;
    const { value } = target;
    const { cropSelected, breedingStationSelected } = this.state;
    const { fetchProjectList } = this.props;
    const findV = this.props.testTypeList.find(t => t.testTypeID === value * 1);
    if (findV) {
      this.setState({
        testTypeID: value * 1,
        testTypeCode: findV.testTypeCode,
        fileName: ''
      });
      const projectDisplay = value * 1 === 4 || value * 1 === 5;
      if (
        cropSelected !== '' &&
        breedingStationSelected !== '' &&
        projectDisplay
      ) {
        this.setState({ threeGBTaskID: '', fileName: '' });
        fetchProjectList(cropSelected, breedingStationSelected, findV.testTypeCode);
      }
    }
  };
  saveTreeObjectData = (
    objectType,
    objectID,
    cropID,
    researchGroupID,
    folderObjectType,
    researchGroupObjectType
  ) => {
    // console.log(objectType, objectID, 'folderID', researchGroupID, 'crop', cropID, folderObjectType, researchGroupObjectType);

    // const calResearchGroupId = folderObjectType == 4 ? researchGroupID : null;
    // if (researchGroupObjectType == null) {
    //   console.log('null');
    // } else {
    //   console.log(researchGroupID);
    // }
    const obj = {
      objectID,
      objectType,
      researchGroupID: folderObjectType == 4 ? researchGroupID : null,
      cropID,
      folderObjectType,
      researchGroupObjectType
    };
    // console.log(obj);
    this.setState(obj);
  };

  existImportPhenomeDateFunc = file => {
    // console.log('existImportPhenomeDateFunc', file);
    const {
      cropID,
      researchGroupID,
      objectType,
      folderObjectType,
      researchGroupObjectType,
      objectID,
      // isolationStatus,
      // threeGBTaskID,
    } = this.state;
    // console.log(file)

    if (objectID === '' || objectType === '') {
      this.props.showError({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please select object from the tree.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
      return null;
    }

    // const ThreeGBType = file.testTypeID === 4 || file.testTypeID === 5;
    const determination = this.props.testTypeList.find(test => test.testTypeID === file.testTypeID);

    const newObj = {
      cropCode: file.cropCode,
      brStationCode: file.breedingStationCode,
      testTypeID: file.testTypeID,
      materialTypeID: file.materialTypeID,
      materialStateID: file.materialstateID,
      containerTypeID: file.containerTypeID,
      plannedDate: file.plannedDate,
      expectedDate: file.expectedDate,
      isolated: file.isolated,

      forcedImport: file.forcedImport || false,

      folderID: researchGroupID,
      objectID: objectID.split('~')[0], // TOD check
      objectType,
      cropID,
      folderObjectType,
      researchGroupObjectType,

      testName: file.fileTitle,
      source: file.source,

      determinationRequired: determination.determinationRequired,
      cumulate: file.cumulate,
      importLevel: file.importLevel,
      fileID: file.fileID
    };
    // console.log(newObj, '===');
    this.props.importPhenome(newObj);
    // this.setState({
    //   todayDate: moment(),
    //   startDate: moment(),
    //   expectedDate: moment().add(14, 'days'),
    //   isolationStatus: false,
    //   cumulateStatus: false,
    //   materialTypeID: 0,
    //   materialStateID: 0,
    //   containerTypeID: 0,
    //   testTypeID: 1,
    //   objectType: '',
    //   researchGroupID: '',
    //   objectID: '',
    //   fileName: '',
    //   cropID: '',
    //   folderObjectType: '',
    //   researchGroupObjectType: ''
    // });
    this.props.toggleVisibility(false);
    return null;
  };
  importPhenomeData = forcedImport => {
    // console.log('importPhenomeData');
    const {
      testTypeID,
      materialStateID,
      materialTypeID,
      containerTypeID,
      startDate,
      expectedDate,
      objectID,
      objectType,
      cropID,
      folderObjectType,
      researchGroupObjectType,
      isolationStatus,
      researchGroupID,
      fileName,
      threeGBTaskID,
      cumulateStatus,

      cropSelected: cropCode,
      breedingStationSelected: brStationCode,
      importLevel,
      importPhemoneExisting
    } = this.state;
    // console.log('importPhemoneExisting ===', importPhemoneExisting);
    if (importPhemoneExisting) {
      const newObj = Object.assign({}, this.props.selectedFile, { forcedImport });
      // console.log(newObj);
      // this.existImportPhenomeDateFunc(newObj, '***');
      this.existImportPhenomeDateFunc(newObj, '***');
      return null;
    }

    const ThreeGBType = testTypeID === 4 || testTypeID === 5 || testTypeID === 6;
    const mmcCondition =
      materialTypeID === 0 || materialStateID === 0 || containerTypeID === 0;
    if (!ThreeGBType && mmcCondition) {
      this.props.showError({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: [
          'Please select Material Type, Material State and Container Type.'
        ],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
      return null;
    }

    if (objectID === '' || objectType === '') {
      this.props.showError({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please select object from the tree.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
      return null;
    }

    if (fileName === '') {
      const fNameMsg = ThreeGBType
        ? 'Please select Project.'
        : 'Please provide file name.';
      this.props.showError({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: [fNameMsg],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
      return null;
    }

    const determination = this.props.testTypeList.find(test => test.testTypeID === testTypeID);
    const importObj = {
      forcedImport,
      cropCode,
      brStationCode,
      testTypeID,
      materialTypeID,
      materialStateID,
      containerTypeID,
      plannedDate: startDate.format(window.userContext.dateFormat),
      expectedDate: expectedDate.format(window.userContext.dateFormat),
      isolated: isolationStatus,
      folderID: researchGroupID,
      objectID: objectID.split('~')[0], // TOD check
      objectType,
      cropID,
      folderObjectType,
      researchGroupObjectType,
      testName: fileName,
      source: 'Phenome',
      determinationRequired: determination.determinationRequired,
      threeGBTaskID,
      cumulate: cumulateStatus,
      importLevel
    };

    // console.log(importObj, '---');
    this.props.importPhenome(importObj);
    /*
    this.setState({
      todayDate: moment(),
      startDate: moment(),
      expectedDate: moment().add(14, 'days'),
      isolationStatus: false,
      cumulateStatus: false,
      materialTypeID: 0,
      materialStateID: 0,
      containerTypeID: 0,
      testTypeID: 1,
      objectType: '',
      researchGroupID: '',
      objectID: '',
      fileName: '',
      cropID: '',
      folderObjectType: '',
      researchGroupObjectType: ''
    });
    */
    this.props.toggleVisibility(false);
    return null;
  };

  adalLogin = () => {
    adalConfig.callback = () => {
      this.props.testLogin(this.getToken());
    };

    runWithAdal(
      authContext(adalConfig),
      () => {
        const tok = this.getToken();
        if (tok) {
          this.props.testLogin(tok);
        }
      },
      false
    );

    // console.log(authContext.getCachedToken(authContext.config.clientId));
    // if (authContext.getCachedToken(authContext.config.clientId)) {
    //   this.props.testLogin(authContext.getCachedToken(authContext.config.clientId));
    // }
  };

  handleAllChange = e => {
    const { target } = e;
    const { value, type, name } = target;
    const val = type === 'checkbox' ? target.checked : value;
    this.setState({ [name]: val });

    if (type !== 'checkbox') {
      this.changeFetch(name, val);
    }
  };

  click = choice => {
    const { importPhemoneExisting, confirmationNo, close } = this.props;
    if (choice) {
      // console.log('yes process , = ', importPhemoneExisting);
      confirmationNo();
      this.importPhenomeData(true);
      close(importPhemoneExisting);
    } else {
      confirmationNo();
    }
  };

  render() {
    const {
      visibility,
      close,
      // toggleVisibility,
      materialTypeList,
      materialStateList,
      containerTypeList,
      testTypeList,
      isLoggedIn,
      crops,
      breedingStation,
      threegbList,
      importPhemoneExisting,
    } = this.props;
    const { cropSelected, breedingStationSelected, importLevel,  warningFlag, warningMessage } = this.state;
    // console.log(threegbList,'threegbList');
    const { testTypeID } = this.state;
    const boxHeight = 400; // 340 // 430;
    const projectList = testTypeID === 4 || testTypeID === 5;
    const s2sType = testTypeID === 6;
    // if (testTypeID !== 4) {
    // if (!projectList) {
    //   boxHeight = 382; // 460; // 340;
    // };

    return (
      <Fragment>
        {warningFlag ? null : (
          <div
            className="import-modal"
            style={{ display: `${visibility ? '' : 'none'}` }}
          >
            <div className="content" style={{ height: boxHeight }}>
              <div className="title">
                <span
                  className="close"
                  onClick={() => {
                    close(importPhemoneExisting);
                    {/*toggleVisibility(false)*/}
                  }}
                  tabIndex="0"
                  onKeyDown={() => {}}
                  role="button"
                >
                  &times;
                </span>
                <span>Import Data from Phenome</span>
              </div>
              <div className="data-section phenome-container">
                <div className="data-section">
                  {importPhemoneExisting && (
                    <div className="body">
                      <div>
                        <label htmlFor="objectID">
                          Selected Object ID
                          <input
                            name="objectID"
                            type="text"
                            value={this.state.objectID}
                            readOnly
                            disabled
                          />
                        </label>
                      </div>
                    </div>
                  )}
                  {!importPhemoneExisting && (
                    <div className="body">
                      <Dropdown
                        label="Test type"
                        options={testTypeList}
                        value={this.state.testTypeID}
                        change={this.handleTestTypeChange}
                      />
                      {!projectList && (
                        <div>
                          <label>Import Level</label>
                          <div className="radioSection">
                            <label htmlFor="plant1" className={importLevel === "PLT" ? 'active' : ''}>
                              <input
                                id="plant1"
                                type="radio"
                                value="PLT"
                                name="importLevel"
                                checked={importLevel === "PLT"}
                                onChange={this.handleAllChange}
                              />
                              Plant
                            </label>
                            <label htmlFor="list1" className={importLevel === "LIST" ? 'active' : ''}>
                              <input
                                id="list1"
                                type="radio"
                                value="LIST"
                                name="importLevel"
                                checked={importLevel === "LIST"}
                                onChange={this.handleAllChange}
                              />
                              List
                            </label>
                          </div>
                        </div>
                      )}
                      {/*
                      <div>
                        <label htmlFor="importTylpe"> Import Type </label>
                        <select value={importType} onChange={this.handleAllChange} name="importType">
                          {this.importTypeList.map(it => <option value={it.id} key={it.id}>{it.type}</option>)}
                        </select>
                      </div>
                      */}
                      {!projectList && !s2sType && (
                        <Fragment>
                          <DateInput label="Planned Week"todayDate={this.state.todayDate} selected={this.state.startDate} change={this.handleDateChange} />
                          <DateInput label="Expected Week"todayDate={this.state.startDate} selected={this.state.expectedDate} change={this.handleExpectedDateChange} />
                        </Fragment>
                      )}
                      {projectList && (
                        <Fragment>
                          <div>
                            <label htmlFor="cropSelected">
                              Crops
                              <select
                                name="cropSelected"
                                onChange={this.handleAllChange}
                              >
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
                          <div>
                            <label htmlFor="threeGBTaskID">
                              Project List
                              <select
                                name="threeGBTaskID"
                                onChange={this.handleAllChange}
                                disabled={
                                  cropSelected === '' || breedingStationSelected === ''
                                }
                                value={this.state.threeGBTaskID}
                              >
                                <option value="">Select</option>
                                {threegbList.map(b => (
                                  <option value={b.threeGBTaskID} key={b.threeGBTaskID}>
                                    {b.week} - {b.threeGBProjectcode}
                                  </option>
                                ))}
                              </select>
                            </label>
                          </div>
                        </Fragment>
                      )}

                      {/*
                        Section will display Form Elements require for s2s test type.
                      */}
                      {s2sType && (
                        <Fragment>
                          <div>
                            <label htmlFor="cropSelected">
                              Crops
                              <select
                                name="cropSelected"
                                onChange={this.handleAllChange}
                              >
                                <option value="">Select</option>
                                {crops.map(c => (
                                  <option value={c} key={c}>
                                    {c}
                                  </option>
                                ))}
                              </select>
                            </label>
                          </div>
                          <Dropdown
                            label="Lab Location"
                            name="materialTypeID"
                            options={materialTypeList}
                            value={this.state.materialTypeID}
                            change={this.handleTypeAndState}
                          />
                          <Dropdown
                            label="Capacity Slot"
                            name="materialTypeID"
                            options={materialTypeList}
                            value={this.state.materialTypeID}
                            change={this.handleTypeAndState}
                          />
                        </Fragment>
                      )}

                      {!projectList && !s2sType && (
                        <Fragment>
                          <Dropdown
                            label="Material Type"
                            name="materialTypeID"
                            options={materialTypeList}
                            value={this.state.materialTypeID}
                            change={this.handleTypeAndState}
                          />
                          <Dropdown
                            label="Material State"
                            name="materialStateID"
                            options={materialStateList}
                            value={this.state.materialStateID}
                            change={this.handleTypeAndState}
                          />
                          <Dropdown
                            label="Container Type"
                            name="containerTypeID"
                            options={containerTypeList}
                            value={this.state.containerTypeID}
                            change={this.handleTypeAndState}
                          />
                        </Fragment>
                      )}
                      <div>
                        <label htmlFor="fileName">
                          File Name
                          <input
                            name="fileName"
                            type="text"
                            value={this.state.fileName}
                            onChange={e => this.setState({ fileName: e.target.value })}
                            disabled={projectList}
                          />
                        </label>
                      </div>
                      <div>
                        <label htmlFor="objectID">
                          Selected Object ID
                          <input
                            name="objectID"
                            type="text"
                            value={this.state.objectID}
                            readOnly
                            disabled
                          />
                        </label>
                      </div>
                      {!projectList && !s2sType && (
                        <div className="markContainer">
                          {/* <label>&nbsp;</label> */} {/*eslint-disable-line*/}
                          <div className="marker">
                            <input
                              type="checkbox"
                              id="isolationModalPhenome1"
                              name="isolationModalPhenome1"
                              checked={this.state.isolationStatus}
                              onChange={this.handleAllChange}
                            />
                            <label htmlFor="isolationModalPhenome1">Already Isolated</label> {/*eslint-disable-line*/}
                          </div>
                        </div>
                      )}
                      {!projectList && !s2sType && (
                        <div className="markContainer">
                          {/* <label>&nbsp;</label> */} {/*eslint-disable-line*/}
                          <div className="marker">
                            <input
                              type="checkbox"
                              id="cumulateStatus1"
                              name="cumulateStatus1"
                              checked={this.state.cumulateStatus}
                              onChange={this.handleAllChange}
                            />
                            <label htmlFor="cumulateStatus1">Cumulate</label> {/*eslint-disable-line*/}
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                  <div className="body2" />
                  <div className="footer">
                    <button onClick={() => this.importPhenomeData(false)}>
                      Import data from Phenome
                    </button>
                  </div>
                </div>

                <div className="phenome-section" style={{ height: boxHeight - 60 }}>
                  {isLoggedIn ? (
                    <Treeview saveTreeObjectData={this.saveTreeObjectData} />
                  ) : (
                    <Fragment>
                      {window.sso.enabled ? (
                        <div className="flexCenterCenter">
                          <button onClick={this.adalLogin}>Phenome Login</button>
                        </div>
                      ) : (
                        <Login />
                      )}
                    </Fragment>
                  )}
                  <br />
                </div>
              </div>
            </div>
          </div>
        )}
        {warningFlag && <ConfirmBox click={this.click} message={warningMessage} />}
      </Fragment>
    );
  }
}
ImportPhenome.defaultProps = {
  threegbList: [],
  crops: [],
  breedingStation: [],
  selectedFile: {},
  warningMessage: []
};
ImportPhenome.propTypes = {
  importPhemoneExisting: PropTypes.bool.isRequired,
  warningFlag: PropTypes.bool.isRequired,
  warningMessage: PropTypes.array, // eslint-disable-line react/forbid-prop-types,
  confirmationNo: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  testLogin: PropTypes.func.isRequired,
  importPhenome: PropTypes.func.isRequired,
  fetchProjectList: PropTypes.func.isRequired,
  showError: PropTypes.func.isRequired,
  visibility: PropTypes.bool.isRequired,
  isLoggedIn: PropTypes.bool.isRequired,
  toggleVisibility: PropTypes.func.isRequired,
  materialTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  materialStateList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  containerTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  testTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  threegbList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  breedingStation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  selectedFile: PropTypes.object // eslint-disable-line react/forbid-prop-types
};
const mapStateToProps = state => ({
  phenomeLogin,
  isLoggedIn: state.phenome.isLoggedIn,
  crops: state.user.crops,
  breedingStation: state.breedingStation.station,
  threegbList: state.assignMarker.threegb,
  selectedFile: state.assignMarker.file.selected,
});
const mapDispatchToProps = dispatch => ({
  importPhenome: data => {
    dispatch(importPhenomeAction(data));
  },
  fetchProjectList: (crop, breeding, testTypeCode) => {
    // console.log(crop, breeding);
    dispatch({
      type: 'THREEGB_PROJECTLIST_FETCH',
      crop,
      breeding,
      testTypeCode
    });
  },
  testLogin: tok => dispatch(phenomeLogin(tok)),
  confirmationNo: () => {
    dispatch({
      type: 'PHENOME_WARNING_FALSE'
    });
  }
});
export default connect(mapStateToProps, mapDispatchToProps)(ImportPhenome);
