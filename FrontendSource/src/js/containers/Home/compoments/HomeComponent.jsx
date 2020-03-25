import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { Redirect, Prompt } from 'react-router-dom';
import shortid from 'shortid';
import moment from 'moment';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import autoBind from 'auto-bind';

import Markers from './Marker/Markers';
import TableData from './TableData';

import ImportData from './Import';

// import ImportFileModal from './ImportFileModal';
// import ImportPhenome from './ImportPhenome/index.jsx';
import ImportExternal from './ImportExternal';
import SelectedFileAttributes from './SelectedFileAttributes';

import ManageMarkerTable from '../ManageMarker';
import ThreeGBMarkTble from '../ThreeGBMark';

import Page from '../../../components/Page/Page';
import Slot from '../../../components/Slot';
import Export from '../../../components/Export';

// import ConfirmBox from '../../../components/Confirmbox/confirmBox';

import { getDim, getStatusName } from '../../../helpers/helper';

import imgExport from '../../../../../public/images/export.gif';
import imgAdd from '../../../../../public/images/add.gif';
import imgAdd2 from '../../../../../public/images/add2.gif';

class HomeComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      todayDate: moment(),
      plannedDate: props.plannedDate,
      expectedDate: props.expectedDate,
      goToPlateFilling: false,

      testID: props.testID,
      testTypeID: props.testTypeID,
      testTypeSelected: props.testTypeSelected,

      slotID: props.slotID,
      // slotList: props.slotList,
      slotVisibility: false,

      sourceList: props.sources,
      phenomeDisplay: true,
      sourceSelected: props.sourceSelected,
      sourceLoginRequired: false,

      loginModalVisibility: false,

      materialTypeList: props.materialTypeList,
      materialStateList: props.materialStateList,
      containerTypeList: props.containerTypeList,

      cropCode: props.cropCode,
      fileDataLength: props.fileDataLength,
      fileID: props.fileID,
      markerstatus: props.markerstatus,

      pageNumber: props.pageNumber || 1,
      pageSize: props.pageSize,
      tblCellWidth: props.tblCellWidth,
      tblWidth: 0, // props.tblWidth,
      tblHeight: 0, // props.tblHeight,

      fixColumn: 0,
      columnLength: props.columnLength,
      markerShow: true,
      isolationSelected: props.isolated || false,
      cumulateSelected: props.cumulate,

      importedFilesAttributesVisibility: false,
      importFileModalVisibility: false,

      importForm: false,

      statusCode: props.statusCode,
      filterLength: props.filterLength,
      selectedTabIndex: 0,
      dirty: props.dirty,
      dirtyMessage: 'There are unsaved changes in Manage Marker & Materials',
      statusList: props.statusList,

      cropSelected: props.cropSelected,
      breedingStation: props.breedingStation,
      breedingStationSelected: props.breedingStationSelected,

      exportVisibility: false,
      importLevel: props.importLevel,

      importPhemoneExisting: props.importPhemoneExisting,

      existingFlag: false,

      warningFlag: props.warningFlag,
      warningMessage: props.warningMessage
    };
    props.pageTitle();
    autoBind(this);
  }

  componentDidMount() {
    window.addEventListener('beforeunload', this.handleWindowClose);
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();

    // this.props.sidemenu();

    // setTimeout(() => {
    this.props.fetchTestType();
    if (this.props.sources.length === 0) {
      this.props.fetchImportSource();
    }

    // if (this.props.token !== null) {
    if (this.props.statusList.length === 0) {
      this.props.getStatusList();
    }

    // fetch material type :: changes added
    if (this.props.materialTypeList.length === 0)
      this.props.fetchMaterialType();
    if (this.props.materialStateList.length === 0)
      this.props.fetchMaterialState();
    if (this.props.containerTypeList.length === 0)
      this.props.fetchContainerType();
    // }, 0);
    // if (this.props.fileList.length === 0) {
    //     this.props.fetchFileList();
    // }

    this.props.fetchBreeding();

    if (this.props.testID) {
      if (this.props.testTypeID !== 4 && this.props.testTypeID !== 5) {
        this.fileFetch(this.props.testID, false);
        // this.props.fetchMaterials(options);
        // this.props.fetchMaterials(options);
      } else {
        const options = {
          testID: this.props.testID,
          pageNumber: 1,
          pageSize: 150,
          filter: this.props.filter
        };
        this.props.fetchThreeGBMark(options);
      }
    }
    // } else {
    //   this.props.checkToken();
    // }
  }

  componentWillReceiveProps(nextProps) {
    // PHEONOME WARNING CONFIRMATION
    if (nextProps.warningFlag !== this.props.warningFlag) {
      this.setState({
        warningFlag: nextProps.warningFlag,
        warningMessage: nextProps.warningMessage
      });
    }
    if (nextProps.importPhemoneExisting !== this.props.importPhemoneExisting) {
      this.setState({
        importPhemoneExisting: nextProps.importPhemoneExisting,
      });
      // console.log('change', nextProps);
    }

    if (nextProps.importLevel !== this.props.importLevel) {
      this.setState({
        importLevel: nextProps.importLevel
      });
    }
    if (nextProps.sources.length !== this.state.sourceList.length) {
      // console.log('source data change');
      this.setState({
        sourceList: nextProps.sources
      });
    }
    if (nextProps.sourceSelected !== this.props.sourceSelected) {
      this.setState({
        sourceSelected: nextProps.sourceSelected
      });
    }
    if (nextProps.cumulate !== this.props.cumulate) {
      this.setState({
        cumulateSelected: nextProps.cumulate
      });
    }
    if (nextProps.cropSelected !== this.props.cropSelected) {
      this.setState({ cropSelected: nextProps.cropSelected });
      if (nextProps.breedingStationSelected !== '') {
        const { cropSelected, breedingStationSelected } = nextProps;
        // console.log(cropSelected, breedingStationSelected);
        this.props.fetchFileList(breedingStationSelected, cropSelected);
        this.props.fetch_testLookup(breedingStationSelected, cropSelected);
      }
    }
    if (nextProps.breedingStation.length !== this.props.breedingStation.length) {
      this.setState({ breedingStation: nextProps.breedingStation });
    }
    if (nextProps.breedingStationSelected !== this.props.breedingStationSelected) {
      this.setState({
        breedingStationSelected: nextProps.breedingStationSelected
      });
      if (nextProps.cropSelected !== '') {
        const { cropSelected, breedingStationSelected } = nextProps;
        // console.log(cropSelected, breedingStationSelected);
        this.props.fetchFileList(breedingStationSelected, cropSelected);
        this.props.fetch_testLookup(breedingStationSelected, cropSelected);
      }
    }

    if (nextProps.filterLength !== this.props.filterLength) {
      this.setState({ filterLength: nextProps.filterLength });
    }
    if (nextProps.statusCode !== this.props.statusCode) {
      this.setState({ statusCode: nextProps.statusCode });
    }
    if (nextProps.statusList !== this.props.statusList) {
      this.setState({ statusList: nextProps.statusList });
    }
    if (nextProps.fileDataLength !== this.props.fileDataLength) {
      this.updateDimensions();
      this.setState({ fileDataLength: nextProps.fileDataLength });
    }
    if (nextProps.testID !== this.props.testID) {
      // alert('change in testID');
      // console.log('nexp prop testID different call', nextProps.testID);
      // this.props.plateFillingPageOne();
      this.setState({ testID: nextProps.testID });
      // this.fileFetch(nextProps.testID, true);
      this.props.fetchSlotList(nextProps.testID);
    }
    if (nextProps.slotID !== this.props.slotID) {
      this.setState({ slotID: nextProps.slotID || 0 });
    }
    if (nextProps.fileList.length > this.props.fileList.length) {
      // console.log('here change to tab 0');
      this.setState({
        selectedTabIndex: 0,
        importForm: false,
        importFileModalVisibility: false
      });
    }
    if (nextProps.fileList) {
      this.setState({ fileList: nextProps.fileList });
    }
    if (nextProps.testTypeID !== this.props.testTypeID) {
      this.setState({ testTypeID: nextProps.testTypeID });
    }
    // locally change
    if (nextProps.testTypeSelected !== this.props.testTypeSelected) {
      this.setState({ testTypeID: nextProps.testTypeSelected });
    }
    if (nextProps.markerstatus !== this.props.markerstatus) {
      this.setState({ markerstatus: nextProps.markerstatus });
    }
    if (nextProps.columnLength !== this.props.columnLength) {
      this.setState({ columnLength: nextProps.columnLength });
    }
    if (nextProps.fileID) {
      this.setState({ fileID: nextProps.fileID });
    }
    if (nextProps.fileName !== this.props.fileName) {
      this.setState({fileName: nextProps.fileName });
    }
    if (nextProps.pageNumber !== this.props.pageNumber) {
      this.setState({pageNumber: nextProps.pageNumber });
    }
    if (nextProps.pageSize !== this.props.pageSize) {
      this.setState({pageSize: nextProps.pageSize });
    }

    if (nextProps.materialTypeList) {
      this.setState({ materialTypeList: nextProps.materialTypeList });
    }
    if (nextProps.materialStateList) {
      this.setState({ materialStateList: nextProps.materialStateList });
    }
    if (nextProps.containerTypeList) {
      this.setState({ containerTypeList: nextProps.containerTypeList });
    }
    if (nextProps.isolated !== this.props.isolated) {
      this.setState({ isolationSelected: nextProps.isolated });
    }
    if (nextProps.plannedDate !== this.props.plannedDate) {
      this.setState({ plannedDate: nextProps.plannedDate });
    }
    if (nextProps.expectedDate !== this.props.expectedDate) {
      this.setState({ expectedDate: nextProps.expectedDate });
    }
    if (nextProps.cropCode !== this.props.cropCode) {
      this.setState({ cropCode: nextProps.cropCode });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.handleWindowClose);
    window.removeEventListener('resize', this.updateDimensions);
    this.props.resetMarkerDirty();
  }

  handleChangeSource = e => {
    const currentSelect = e.target.value;
    // const { sourceList } = this.state;
    // const i = sourceList.find(source => source.code === currentSelect);
    // console.log(currentSelect);
    this.props.ImportSourceChange(currentSelect);
    this.setState({
      sourceSelected: currentSelect
      // sourceLoginRequired: i.loginRequired
    });
  };

  handleChangeTabIndex = index => {
    this.setState({ selectedTabIndex: index });
  };

  handleWindowClose(e) {
    if (this.props.dirty) {
      e.returnValue = true;
    }
  }

  updateDimensions() {
    const dim = getDim();
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  }

  // _goToPlateFilling() {
  //   this.setState({ goToPlateFilling: true });
  // }

  _markerShowToggle() {
    this.setState({ markerShow: !this.state.markerShow });
  }

  // _dateChange(date) {
  //   this.setState({ plannedDate: date });
  // }

  _fixColumn(e) {
    this.setState({ fixColumn: e.target.value });
  }

  fileChange(e) {
    if (this.props.dirty) {
      if (confirm(this.state.dirtyMessage)) { // eslint-disable-line
        if (e.target.value) this.fileFetch(e.target.value, true);
        this.updateDimensions();
        this.setState({ selectedTabIndex: 0 });
        this.props.resetMarkerDirty();
      }
    } else {
      if (e.target.value) this.fileFetch(e.target.value, true);
      this.updateDimensions();
      this.setState({ selectedTabIndex: 0 });
    }
  }
  fileFetch(value, filechange = false) {
    if (value !== '') {
      const selectedFile = this.props.fileList.find(
        file => file.testID === value * 1
      );
      // console.log(selectedFile);
      if (selectedFile) {
        this.props.selectFile(selectedFile);

        selectedFile.pageNumber =
          this.state.pageNumber || this.props.pageNumber;

        selectedFile.pageSize = this.state.pageSize || this.props.pageSize;
        selectedFile.filter = this.props.filter;

        // console.log(selectedFile);
        this.props.assignData(selectedFile, filechange);
      }
    }
  }

  clearFilter() {
    // clear filter :: handled in fetch data call
    // fetch data
    const obj = {
      testID: this.state.testID,
      testTypeID: this.state.testTypeID,
      filter: [],
      pageNumber: 1,
      pageSize: this.props.pageSize
    };
    this.props.clearFilterFetch(obj);
    // clearFilter
  }

  toggleImportedFilesAttributesVisibility() {
    this.setState({
      importedFilesAttributesVisibility: !this.state
        .importedFilesAttributesVisibility
    });
  }

  toggleImportFileModalVisibility() {
    if (this.props.dirty) {
      if (confirm(this.state.dirtyMessage)) { // eslint-disable-line
        this.props.resetMarkerDirty();
        this.setState({
          importFileModalVisibility: !this.state.importFileModalVisibility
        });
      }
    } else {
      this.setState({
        importFileModalVisibility: !this.state.importFileModalVisibility
      });
    }
  }

  /**
   * Show Phenome Import Form
   * And Flag Existing Test or New Test
   * @param  {boolen} existingFlag
   * @return {null}
   */
  phenomeImportExistingFormUI = existingFlag => {
    this.setState({
      importForm: true,
      existingFlag
    });
  }
  PhenomeImportFormUI = () => {
    const { existingFlag } = this.state;
    const pt = document.getElementsByClassName('phenome-treeview');
    if (pt.length === 1) {
      pt[0].scrollTop = 0;
      pt[0].scrollLeft = 0;
    }
    if (this.props.dirty) {
      if (confirm(this.state.dirtyMessage)) { // eslint-disable-line
        this.props.resetMarkerDirty();
        this.friendlyToggle(existingFlag);
        // this.friendlyToggle(existingImport);
      }
    } else {
      this.friendlyToggle(existingFlag);
      // this.friendlyToggle(existingImport);
    }
  };
  friendlyToggle = existingImport => {
    this.setState({
      importForm: !this.state.importForm,
      importPhemoneExisting: existingImport
    });
  };

  toggleSlotVisibility() {
    this.setState({ slotVisibility: !this.state.slotVisibility });
  }

  toggleLoginVisibility() {
    this.setState({ loginModalVisibility: !this.state.loginModalVisibility });
  }
  // fetch data in each switch of tab to get fresh data from server
  // tabIndex 0 = Selected & Assigned tab
  // tabIndex 1 = New tab or Editable tab.
  fetchTabData(tabIndex) {
    const { testID, testTypeID, pageSize } = this.state;
    // const { fileID } = this.props;
    const options = { testID, pageNumber: 1, pageSize };
    // console.log(this.props.dirty, tabIndex);
    if (this.props.dirty) {
      // console.log('fetch dirty');
      if (confirm(this.state.dirtyMessage)) { // eslint-disable-line
        this.props.resetMarkerDirty();
        if (tabIndex === 0) {
          this.fileFetch(testID, false);
        } else if (tabIndex === 1) {
          if (this.props.selectedFileSource === 'External') {
            // alert(1);
            this.props.fetchMaterialDeterminationsForExternalTest(options);
          } else if (testTypeID !== 2 && testTypeID !== 4 && testTypeID !== 5) {
            // alert(2);
            this.props.fetchMaterials(options);
          } else {
            // alert(3);
            this.props.fetchThreeGBMark(options);
          }
        }
        this.setState({ selectedTabIndex: tabIndex });
      }
    } else {
      if (tabIndex === 0) {
        this.fileFetch(testID, false);
      } else if (tabIndex === 1) {
        const newOptions = Object.assign(options, { filter: [] });
        // const options = {
        //   testID,
        //   pageNumber: 1,
        //   pageSize: 150,
        //   filter: []
        // };
        // console.log('testTypeID', testTypeID);

        if (this.props.selectedFileSource === 'External') {
          this.props.fetchMaterialDeterminationsForExternalTest(newOptions);
        } else if (testTypeID !== 2 && testTypeID !== 4 && testTypeID !== 5) {
          this.props.fetchMaterials(newOptions);
        } else {
          // console.log('newOptions', newOptions);
          this.props.fetchThreeGBMark(newOptions);
        }
      }
      this.setState({
        selectedTabIndex: tabIndex
      });
    }
  }
  // 2018/08/15
  cropSelectFn = e => {
    const { value } = e.target;
    if (value !== '') {
      this.props.emptyRowColumns();
      this.props.cropSelect(value);
    }
  };

  breedingStationSelectionFn = e => {
    const { value } = e.target;
    if (value !== '') {
      // console.log(value);
      this.props.emptyRowColumns();
      this.props.breedingStationSelect(value);
    }
  };

  sendtothreeGBCockpit = () => {
    // console.log('testID', this.state.testID);
    // console.log('filter', this.props.filter);
    if (confirm("Are you sure, send to 3GB Cockpit ?")) { // eslint-disable-line
      this.props.sendTOThreeGBCockPit(this.state.testID, this.props.filter);
    }
  };

  addToThreeGBList = () => {
    const { testID, filter } = this.props;
    this.props.addToThreeGB(testID, filter);
  };

  exportVisibilityToggle = () => {
    const { exportVisibility } = this.state;
    this.setState({
      exportVisibility: !exportVisibility
    });
  };

  exportUI = () => {
    const { exportVisibility: visible } = this.state;
    return visible ? <Export close={this.exportVisibilityToggle} /> : null;
  };
  slotUI = () => {
    const { slotVisibility: visible, testID } = this.state;
    return visible ? (
      <Slot testID={testID} toggleVisibility={this.toggleSlotVisibility} />
    ) : null;
  };
  importUI = () => {
    return null;
    const { testTypeList } = this.props;
    const { sourceSelected, materialTypeList, materialStateList,
      containerTypeList, importFileModalVisibility,
      existingFlag, fileID, warningFlag, warningMessage } = this.state;

    if (sourceSelected === 'Phenome') {
      return (
        <ImportPhenome
          testTypeList={testTypeList}
          materialTypeList={materialTypeList}
          materialStateList={materialStateList}
          containerTypeList={containerTypeList}
          visibility={importPhemoneVisibility}
          toggleVisibility={() => {}}
          close={this.friendlyToggle}
          changeTabIndex={this.handleChangeTabIndex}
          showError={this.props.showError}
          importPhemoneExisting={existingFlag}
          fileID={fileID}
          warningFlag={warningFlag}
          warningMessage={warningMessage}
        />
      );
    }
    if (sourceSelected === 'External') {
      return (
        <ImportExternal
          testTypeList={testTypeList}
          materialTypeList={materialTypeList}
          materialStateList={materialStateList}
          containerTypeList={containerTypeList}
          visibility={importFileModalVisibility}
          toggleVisibility={this.toggleImportFileModalVisibility}
          changeTabIndex={this.handleChangeTabIndex}
        />
      );
    }
    return null;
    // sourceSelected === 'Breezys'
    /*return (
      <ImportFileModal
        testTypeList={testTypeList}
        materialTypeList={materialTypeList}
        materialStateList={materialStateList}
        containerTypeList={containerTypeList}
        visibility={importFileModalVisibility}
        toggleVisibility={this.toggleImportFileModalVisibility}
        changeTabIndex={this.handleChangeTabIndex}
      />
    );*/
  };
  selectedAttributeUI = () => {
    const { testID, showError, testTypeList } = this.props;
    const {
      importedFilesAttributesVisibility,
      materialTypeList,
      materialStateList,
      containerTypeList,
      isolationSelected,
      plannedDate,
      expectedDate,
      fileList,
      slotID,
      testTypeID,
      cropCode,
      breedingStationSelected,
      statusCode,
      cumulateSelected
    } = this.state;

    return testID ? (
      <SelectedFileAttributes
        cumulate={cumulateSelected}
        visibility={importedFilesAttributesVisibility}
        materialTypeList={materialTypeList}
        materialStateList={materialStateList}
        containerTypeList={containerTypeList}
        isolationStatus={isolationSelected}
        plannedDate={plannedDate}
        expectedDate={expectedDate}
        testID={this.state.testID}
        fileList={fileList}
        slotID={slotID}
        testTypeID={testTypeID}
        cropCode={cropCode}
        breeding={breedingStationSelected}
        statusCode={statusCode}
        showError={showError}
        updateTestAttributes={this.props.updateTestAttributes}
        testTypeList={testTypeList}
      />
    ) : null;
  };

  filterClearUI = () => {
    const { filter: filterLength } = this.props;
    if (filterLength < 1) return null;
    return (
      <button className="with-i" onClick={this.clearFilter}>
        <i className="icon icon-cancel" />
        Clear filters
      </button>
    );
  };

  importFormClose = flag => {
    const { importForm } = this.state;
    if (importForm)
      this.setState({ importForm: false });
  };

  render() {
    const { testID } = this.props;
    const { fixColumn, tblHeight, tblWidth, tblCellWidth,
      slotID, testTypeID, sourceSelected, sourceList, breedingStation,
      breedingStationSelected, importLevel, markerstatus, fileID } = this.state;
    // dispaly state
    const { goToPlateFilling, phenomeDisplay, warningFlag } = this.state;
    const { statusCode, platePlanName } = this.props;
    const colRecords = this.state.columnLength;

    const secondTab = markerstatus || importLevel === "LIST";
    const ThreeGBType = testTypeID === 4 || testTypeID === 5;
    const noThreeGBType = testTypeID !== 4 && testTypeID !== 5;

    // DNA save button and Mange DNA tab option remove as requeste
    const isDNA = false; // testTypeID === 2;

    const cropStationPhenome = sourceSelected === 'Phenome'
      && statusCode <= 200
      && this.state.cropSelected !== ''
      && breedingStationSelected !== ''
      && fileID !== null;

    if (goToPlateFilling) {
      return <Redirect to="/platefilling" />;
    }

    // getting slot name quick fix
    let slotName = '';
    if (slotID !== '') {
      this.props.slotList.map(s => {
        const { slotID: vSlotID, slotName: sname } = s;
        if (vSlotID === slotID) {
          slotName = sname;
        }
        return null;
      });
    }

    const navActionSlot = statusCode <= 150 && noThreeGBType;
    // console.log(this.props.selectedFileSource);
    return (
      <div>
        <Prompt when={this.props.dirty} message={this.state.dirtyMessage} />
        {/*{this.importUI()}*/}
        {this.exportUI()}
        {this.slotUI()}


        <section className="page-action">
          <div className="left">
            <div className="form-e">
              <label>Crops</label>
              <select
                name="crops"
                id="crops"
                onChange={this.cropSelectFn}
                value={this.state.cropSelected}
              >
                <option value="">Select</option>
                {this.props.crops.map(crop => (
                  <option value={crop} key={crop}>
                    {crop}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-e">
              <label>Br.Station</label>
              <select
                name="breeding"
                id="breeding"
                onChange={this.breedingStationSelectionFn}
                value={breedingStationSelected}
              >
                <option value="">Select</option>
                {breedingStation.map(breed => {
                  const { breedingStationCode } = breed;
                  return (
                    <option
                      key={breedingStationCode}
                      value={breedingStationCode}
                    >
                      {breedingStationCode}
                    </option>
                  );
                })}
              </select>
            </div>
            <div className="form-e">
              <label>Imported</label>
              <select
                name="imported"
                className="w-200"
                value={this.state.testID || ''}
                onChange={this.fileChange}
              >
                <option value="">Select</option>
                {this.props.fileList.map(file => (
                  <option key={shortid.generate()} value={file.testID}>
                    {file.fileTitle}
                  </option>
                ))}
              </select>
              <div
                style={{
                  display: `${this.state.testID ? 'block' : 'none'}`
                }}
                className="btn-detail"
                role="button"
                tabIndex={0}
                title="Toggle marker"
                onKeyPress={() => {}}
                onClick={this.toggleImportedFilesAttributesVisibility}
              >
                {/*
                {this.state.importedFilesAttributesVisibility
                ? 'Show Less '
                : 'Show More '}
              */}
                <i
                  className={
                    this.state.importedFilesAttributesVisibility
                      ? 'icon icon-up-open'
                      : 'icon icon-down-open'
                  }
                />
              </div>
            </div>
            {phenomeDisplay && (
              <div className="form-e">
                <label>Source</label>
                <select
                  name="source"
                  value={sourceSelected}
                  onChange={this.handleChangeSource}
                >
                  {sourceList.map(source => (
                    <option key={source.sourceID} value={source.code}>
                      {source.sourceName}
                    </option>
                  ))}
                </select>
              </div>
            )}

            <div className="fileUpload">
              <span
                title="Import New File"
                className="import -file-icon"
                onClick={() => this.phenomeImportExistingFormUI(false)}
                role="button"
                onKeyDown={() => { }}
                tabIndex={0}
              >
                <img src={imgAdd} alt="" />

                {/* <i className="icon icon-doc-new-circled" /> */}
              </span>
              {sourceSelected === 'External' && (
                <span
                  title="Export"
                  className="import -file-icon"
                  onClick={this.exportVisibilityToggle}
                  role="button"
                  onKeyDown={() => { }}
                  tabIndex={0}
                >
                  <img src={imgExport} alt="" />
                  {/* <i className="icon icon-export-alt" /> */}
                </span>
              )}
            </div>
            {cropStationPhenome && (
              <div className="fileUpload">
                <span
                title="Import to Existing File"
                className="import -file-icon"
                id="importExistingFile"
                onClick={() => this.phenomeImportExistingFormUI(true)}
                role="button"
                onKeyDown={() => { }}
                tabIndex={0}
              >
                <img src={imgAdd2} alt="" />
              </span>
              </div>
            )}
          </div>
        </section>

        <section className="page-action"style={{ display: testID ? 'flex' : 'none' }} >
          <div className="left">
            {this.filterClearUI()}
            {slotName !== '' && (
              <div className="form-e status-txt">
                <label className="full">
                  Slot
                  {': '}
                  {slotName}
                </label>
              </div>
            )}
            {platePlanName && (
              <div className="form-e status-txt">
                <label className="full">
                  Plateplan
                  {': '}
                  {platePlanName}
                </label>
              </div>
            )}
          </div>
          <div className="right">
            <div className="form-e status-txt">
              <label className="full">
                Status{' '}
                {getStatusName(this.state.statusCode, this.state.statusList)}
              </label>
            </div>
            {navActionSlot && (
              <button
                title="Slot"
                className="with-i"
                onClick={e => {
                  e.preventDefault();
                  this.toggleSlotVisibility();
                }}
              >
                <i className="icon icon-plus-squared" />
                <span>Slot</span>
              </button>
            )}
            {/*

            */}
            {testID && (
              <Fragment>
                <button
                  title="Delete"
                  className="with-i"
                  onClick={e => {
                    e.preventDefault();
                    if (confirm("Are sure to delete test?")) {
                      this.props.deleteTest(testID);
                    }
                  }}
                >
                  <i className="icon icon-trash" />
                  <span>Delete</span>
                </button>
                <button
                  title="Remarks"
                  className="with-i"
                  onClick={e => {
                    e.preventDefault();
                    this.props.showRemarks();
                  }}
                >
                  <i className="icon icon-commenting" />
                  <span>Remarks</span>
                </button>
              </Fragment>
            )}
            {ThreeGBType && (
              <button
                title="Send to 3GB Cockpit"
                className="with-i"
                onClick={this.sendtothreeGBCockpit}
              >
                <i className="icon icon-paper-plane" />
                Send to 3GB Cockpit
              </button>
            )}
          </div>
        </section>

        <div className="container">{this.selectedAttributeUI()}</div>
        <div className="container">
          <div className="trow">
            <div className="tcell tabbedData" id="tableWrap">

              {testID && (
                <Tabs
                  className=""
                  onSelect={tabIndex => this.fetchTabData(tabIndex)}
                  selectedIndex={this.state.selectedTabIndex}
                >
                  <TabList>
                    <Tab>Selected &amp; Assigned</Tab>
                    {secondTab && <Tab>Manage Markers &amp; Materials </Tab>}
                    {ThreeGBType && <Tab>Manage 3GB </Tab>}
                    {isDNA && <Tab>Manage DNA </Tab>}
                  </TabList>

                  <TabPanel>
                    <div>
                      <Markers
                        status={this.state.markerstatus}
                        show={this.state.markerShow}
                        collapse={this._markerShowToggle}
                      />
                    </div>

                    {ThreeGBType && (
                      <div className="trow marker">
                        <button
                          onClick={this.addToThreeGBList}
                          title="Add to 3GB"
                          className="icon"
                        >
                          <i className="icon icon-ok-squared" />
                          Add to 3GB
                        </button>
                      </div>
                    )}

                    {isDNA && (
                      <div className="trow marker">
                        <button
                          onClick={this.addToThreeGBList}
                          title="Add to Selected"
                          className="icon"
                        >
                          <i className="icon icon-ok-squared" />
                          Save Selected
                        </button>
                      </div>
                    )}

                    {colRecords ? (
                      <TableData
                        {...this.state}
                        tableCellWidth={tblCellWidth}
                        tblHeight={tblHeight}
                        tblWidth={tblWidth}
                        show={this.state.markerShow}
                        fixColumn={fixColumn}
                        visibility={
                          this.state.importedFilesAttributesVisibility
                        }
                      />
                    ) : (
                      ''
                    )}
                    <Page
                      testID={this.props.testID}
                      pageNumber={this.props.pageNumber}
                      pageSize={this.props.pageSize}
                      records={this.props.records}
                      filter={this.props.filter}
                      onPageClick={this.props.pageClick}
                      isBlocking={false}
                      isBlockingChange={() => {}}
                      pageClicked={() => {}}
                      _fixColumn={this._fixColumn}
                      clearFilter={this.clearFilter}
                      filterLength={this.props.filterLength}
                    />
                  </TabPanel>
                  {secondTab && (
                    <TabPanel>
                      <ManageMarkerTable
                        sample={importLevel === "LIST"}
                        tblHeight={tblHeight}
                        tblWidth={tblWidth}
                        tableCellWidth={tblCellWidth}
                        fixColumn={0}
                        dirtyMessage={this.state.dirtyMessage}
                        visibility={
                          this.state.importedFilesAttributesVisibility
                        }
                      />
                    </TabPanel>
                  )}

                  {ThreeGBType && (
                    <TabPanel>
                      <ThreeGBMarkTble
                        tblHeight={tblHeight}
                        tblWidth={tblWidth}
                        tableCellWidth={tblCellWidth}
                        fixColumn={0}
                        dirtyMessage={this.state.dirtyMessage}
                        visibility={
                          this.state.importedFilesAttributesVisibility
                        }
                        testTypeID={testTypeID}
                      />
                    </TabPanel>
                  )}

                  {isDNA && (
                    <TabPanel>
                      <ThreeGBMarkTble
                        tblHeight={tblHeight}
                        tblWidth={tblWidth}
                        tableCellWidth={tblCellWidth}
                        fixColumn={0}
                        dirtyMessage={this.state.dirtyMessage}
                        visibility={
                          this.state.importedFilesAttributesVisibility
                        }
                        testTypeID={testTypeID}
                      />
                    </TabPanel>
                  )}
                </Tabs>
              )}
            </div>
          </div>
        </div>

        {this.state.importForm &&
          <ImportData
            sourceSelected={sourceSelected}
            existFile={this.state.existingFlag}
            handleChangeTabIndex={this.handleChangeTabIndex}
            showError={this.props.showError}
            close={this.importFormClose}
          />
        }
        {/*<ConfirmBox click={() => alert('click')} message="test" />*/}
      </div>
    );
  }
}
HomeComponent.defaultProps = {
  sources: [],
  sourceSelected: '',
  cumulate: false,
  platePlanName: '',
  selectedFileSource: '',
  fileName: '',
  expectedDate: '',
  cropSelected: '',
  breedingStationSelected: '',
  breedingStation: [],
  slotList: [],
  crops: [],
  testTypeSelected: null,
  cropCode: null,
  statusCode: null,
  testTypeID: 1,
  fileID: null,
  isolated: null,
  testID: null,
  slotID: 0,
  token: null,
  tblCellWidth: 120,
  tblHeight: 400,
  tblWidth: 600,
  plannedDate: ''
};
HomeComponent.propTypes = {
  sources: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  sourceSelected: PropTypes.string,

  cumulate: PropTypes.bool,
  platePlanName: PropTypes.string,
  selectedFileSource: PropTypes.string,
  cropSelected: PropTypes.string,
  breedingStationSelected: PropTypes.string,
  slotList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  breedingStation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  plannedDate: PropTypes.string,
  expectedDate: PropTypes.string,
  cropCode: PropTypes.string,
  fileName: PropTypes.string,
  statusCode: PropTypes.number,
  tblWidth: PropTypes.number,
  tblHeight: PropTypes.number,
  testID: PropTypes.number,
  slotID: PropTypes.number, // eslint-disable-line
  testTypeID: PropTypes.number,
  testTypeSelected: PropTypes.number,
  fileDataLength: PropTypes.number.isRequired,
  pageNumber: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  tblCellWidth: PropTypes.number,
  columnLength: PropTypes.number.isRequired,
  filterLength: PropTypes.number.isRequired,
  records: PropTypes.number.isRequired,
  fileID: PropTypes.number,
  markerstatus: PropTypes.bool.isRequired,
  isolated: PropTypes.bool,
  dirty: PropTypes.bool.isRequired,
  crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  materialTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  materialStateList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  containerTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  statusList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  fileList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  testTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  fetchSlotList: PropTypes.func.isRequired,
  fetchImportSource: PropTypes.func.isRequired,
  ImportSourceChange: PropTypes.func.isRequired,
  fetchMaterialDeterminationsForExternalTest: PropTypes.func.isRequired,
  emptyRowColumns: PropTypes.func.isRequired,
  breedingStationSelect: PropTypes.func.isRequired,
  fetchThreeGBMark: PropTypes.func.isRequired,
  addToThreeGB: PropTypes.func.isRequired,
  cropSelect: PropTypes.func.isRequired,
  sendTOThreeGBCockPit: PropTypes.func.isRequired,
  fetch_testLookup: PropTypes.func.isRequired,
  fetchBreeding: PropTypes.func.isRequired,
  pageTitle: PropTypes.func.isRequired,
  sidemenu: PropTypes.func.isRequired,
  getStatusList: PropTypes.func.isRequired,
  fetchMaterialType: PropTypes.func.isRequired,
  fetchMaterialState: PropTypes.func.isRequired,
  fetchContainerType: PropTypes.func.isRequired,
  fetchFileList: PropTypes.func.isRequired,
  fetchTestType: PropTypes.func.isRequired,
  resetMarkerDirty: PropTypes.func.isRequired,
  selectFile: PropTypes.func.isRequired,
  assignData: PropTypes.func.isRequired,
  clearFilterFetch: PropTypes.func.isRequired,
  fetchMaterials: PropTypes.func.isRequired,
  showRemarks: PropTypes.func.isRequired,
  showError: PropTypes.func.isRequired,
  updateTestAttributes: PropTypes.func.isRequired,
  pageClick: PropTypes.func.isRequired,
  token: PropTypes.string,
  deleteTest: PropTypes.func.isRequired,
  // checkToken: PropTypes.func.isRequired
};

export default HomeComponent;
