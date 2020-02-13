import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import moment from 'moment';

import { runWithAdal } from 'react-adal';
import { adalConfig, authContext } from '../../auth';

import TwoGB from './components/TwoGB';
import SeedTwoSeed from './components/SeedTwoSeed';
import ThreeGB from './components/ThreeGB';
import Exist from './components/Exist';

import Login from '../../ImportPhenome/Login';
import Treeview from '../../ImportPhenome/Treeview';
import ConfirmBox from '../../../../../components/Confirmbox/confirmBox';

import { phenomeLogin, importPhenomeAction } from '../../../actions/phenome';

const initPhenome = {
    importLevel: 'PLT',

    todayDate: moment(),
    startDate: moment(),
    expectedDate: moment().add(14, 'days'),

    materialTypeID: '',
    materialStateID: '',
    containerTypeID: '',

    fileName: '',

    objectID: '',
    objectType: '',
    researchGroupID: '',
    cropID: '',
    folderObjectType: '',
    researchGroupObjectType: '',

    isolationStatus: false,
    cumulateStatus: false,

    // 3GB
    threeGBTaskID: '',
    cropSelected: '',
    breedingStationSelected: '',
    threeGBTaskID: '',

    // Confirm
    warningFlag: false,
    warningMessage: 'test'
};

class Phenome extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            testType: 'MT',

            ...initPhenome,
            sourceSelected: props.sourceSelected,
            existFile: props.existFile,

            // Confirm
            warningFlag: props.warningFlag,
            warningMessage: props.warningMessage
        }
    }
    componentWillReceiveProps(nextProps) {
      if (nextProps.warningFlag !== this.props.warningFlag) {
        this.setState({
          warningFlag: nextProps.warningFlag,
          warningMessage: nextProps.warningMessage
        });
      }
    }

    handleChange = e => {
        const { target } = e;
        const {  name, value, type } = target;
        // console.log(name, value, type);

        this.setState({
            [name]: type === "text"
                ? value : type === 'checkbox'
                ? target.checked : value * 1
                ? value * 1 : value
        });
        if (name === 'testType') {
            this.resetState();
        }
        // IN 3GB type getting filename
        if (name === 'threeGBTaskID') {
            const { threegbList } = this.props;
            // alert(1);
            const projectName = threegbList.find(x => x.threeGBTaskID === value * 1);
            // console.log('tt', tt);
            // const { threeGBProjectcode: fileName } = projectName;
            this.setState({
                fileName: projectName.threeGBProjectcode || ''
            }); // threeGBProjectcode
        }
        if (type !== 'checkbox') {
            // console.log(name, value);
            this.changeFetch(name, value);
        }
    };

    handlePlannedDateChange = date => {
        this.setState({
            startDate: date,
            expectedDate: moment(date).add(14, 'days')
        });
    };
    handleExpectedDateChange = date => {
        this.setState({ expectedDate: date });
    };

    testTypeUI = () => (
      <div>
        <label>
            Test Type
            <select name="testType" value={this.state.testType} onChange={this.handleChange}>
                {this.props.testTypeList.map(x => (
                    <option key={x.testTypeCode} value={x.testTypeCode}>
                        {x.testTypeName}
                    </option>
                ))}
            </select>
        </label>
    </div>
    );
    testComponentUI = testType => {
        // console.log(this.props);
        const { existFile } = this.props;
        if (existFile) return (
          <Exist  {...this.state}
          />
        );

        if (testType === 'DI' || testType === 'MT') return (
            <Fragment>
            {this.testTypeUI()}
            <TwoGB {...this.props}
                handleChange={this.handleChange}
                handlePlannedDateChange={this.handlePlannedDateChange}
                handleExpectedDateChange={this.handleExpectedDateChange}
                { ...this.state }
            />
            </Fragment>
        )

        if (testType === 'S2S') return (
            <Fragment>
            {this.testTypeUI()}
            <SeedTwoSeed  {...this.props}
                handleChange={this.handleChange}
                handlePlannedDateChange={this.handlePlannedDateChange}
                handleExpectedDateChange={this.handleExpectedDateChange}
                { ...this.state }
            />
            </Fragment>
        )

        return (
            <Fragment>
            {this.testTypeUI()}
            <ThreeGB {...this.props}
                handleChange={this.handleChange}
                { ...this.state }
            />
            </Fragment>
        );
    };

    getToken = () => sessionStorage.getItem('adal.idtoken');

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
    };

    resetState = () => { this.setState({ ...initPhenome }) };

    changeFetch = (name, value) => {
      if (name === 'threeGBTaskID') {
        const { testTypeID } = this.state;
        const { threegbList } = this.props;
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

      const { cropSelected, breedingStationSelected, testType } = this.state;
      const { fetchProjectList } = this.props;
      if (name === 'cropSelected') {
        if (breedingStationSelected !== '') {
          fetchProjectList(value, breedingStationSelected, testType);
        }
        this.setState({ threeGBTaskID: '', fileName: '' });
      }
      if (name === 'breedingStationSelected') {
        if (cropSelected !== '' && value !== '') {
          fetchProjectList(cropSelected, value, testType);
        }
        this.setState({ threeGBTaskID: '', fileName: '' });
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

    showErrorFunc = message => {

        this.props.showError({
          type: 'NOTIFICATION_SHOW',
          status: true,
          message,
          messageType: 2,
          notificationType: 0,
          code: ''
        });
    };

    importPhenomeData = forcedImport => {
        const {
          testType,
          materialTypeID, materialStateID, containerTypeID,
          objectID, objectType,
          fileName,
          startDate, expectedDate,
          cropID, folderObjectType, researchGroupObjectType, researchGroupID,
          isolationStatus, cumulateStatus,
          threeGBTaskID,
          cropSelected: cropCode, breedingStationSelected: brStationCode,
          sourceSelected: source,
          importLevel,
          existFile
        } = this.state;

        if (existFile) {
          const { selectedFile: file } = this.props;

          const determination = this.props.testTypeList.find(test => test.testTypeCode === testType);
          const { testTypeID, determinationRequired } = determination;
          // const newObj = Object.assign({}, this.props.selectedFile, { forcedImport });
          // console.log(file);
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

            forcedImport,

            folderID: researchGroupID,
            objectID: objectID.split('~')[0], // TOD check
            objectType,
            cropID,
            folderObjectType,
            researchGroupObjectType,

            testName: file.fileTitle,
            source: file.source,

            determinationRequired,
            cumulate: file.cumulate,
            importLevel: file.importLevel,
            fileID: file.fileID
          };
          // console.log(newObj);
          // this.existImportPhenomeDateFunc(newObj, '***');
          this.props.importPhenome(newObj);
          return null;
        }

        let inValid = false, messageArray = [];

        const ThreeGBType = testType === 'S2S' || testType === 'GMAS' || testType === '3GBProject';
        const mmcCondition = materialTypeID === '' || materialStateID === '' || containerTypeID === '';

        // console.log(this.state);

         if (!ThreeGBType && mmcCondition) {
            inValid = true;
            messageArray.push('Please select Material Type, Material State and Container Type.');
         }

         if (objectID === '' || objectType === '') {
           inValid = true;
            messageArray.push('Please select object from the tree.');
         }

         if (fileName === '') {
           const fNameMsg = ThreeGBType
            ? 'Please select Project.'
            : 'Please provide file name.';
            inValid = true;
            messageArray.push(fNameMsg);
         }

         if (inValid) {
            this.showErrorFunc(messageArray);
            return null;
         }
         const determination = this.props.testTypeList.find(test => test.testTypeCode === testType);
         const { testTypeID, determinationRequired } = determination;
         // console.log(determination);
          // forcedImport: forcedImport,
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
          source,
          determinationRequired,
          threeGBTaskID,
          cumulate: cumulateStatus,
          importLevel
         };
         // console.log(importObj);
         this.props.importPhenome(importObj);
    };
    forceConfirm = choice => {
      const { importPhemoneExisting, confirmationNo, close } = this.props;
      if (choice) {
        confirmationNo();
        this.importPhenomeData(true);
      } else {
        confirmationNo();
      }
    };

    render() {
        const { testType, warningFlag, warningMessage } = this.state;
        // console.log(this.state);
        return (
            <Fragment>
            <div className="import-modal">
                <div className="content">
                    <div className="title">
                      <span
                        className="close"
                        onClick={this.props.close}
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
                            <div className="body">
                              {this.testComponentUI(testType)}
                            </div>
                            <div className="body2" />
                            <div className="footer">
                              <button onClick={() => this.importPhenomeData(false)}>
                                Import data from Phenome
                              </button>
                            </div>
                        </div>
                        <div className="phenome-section">
                            {this.props.isLoggedIn ? (
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
                        </div>
                    </div>
                    <hr />
                </div>
            </div>
            {warningFlag && <ConfirmBox click={this.forceConfirm} message={warningMessage} />}
            </Fragment>
        );
    }
}

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
export default connect(mapStateToProps, mapDispatchToProps)(Phenome);

/////////////////////////////
/// testTypeID -
/// importLevel
///
/// todayData
/// startDate
/// expectedDate
///
/// materialTypeID -
/// materialStateID -
/// containerTypeID -
///
/// fileName
/// isolationStatus (Bool)
/// cumulateStatus  (Bool)
///
/// objectID
/// objectType
/// researchGroupID
/// cropID
/// folderObjectType
///


