import React from 'react';
import autoBind from 'auto-bind';
import Autosuggest from 'react-autosuggest';
import PropTypes from 'prop-types';

import { Redirect, Prompt, Link } from 'react-router-dom';
import TableData from './TableData/TableData';
import ConfirmBox from '../../../components/Confirmbox/confirmBox';
import Page from '../../../components/Page/Page';
import Pagesize from '../../../components/Pagesize/Pagesize';
import Slot from '../../../components/Slot/index';

import { checkStatus, getDim, getStatusName } from '../../../helpers/helper';
import { wellSuggestion, wellSuggestionValue, wellSuggestions } from '../help';

class PlateFillingComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      goToAssignMarker: false,
      cropCode: props.cropCode,
      fileID: props.fileID,
      testID: props.testID,
      testTypeID: props.testTypeID,
      testTypeName: '',
      statusCode: props.statusCode,
      remarkRequired: props.remarkRequired,
      pageNumber: props.pageNumber,
      pageSize: props.pageSize,
      tblCellWidth: props.tblCellWidth,
      tblWidth: 0,
      tblHeight: 0,
      fixColumn: 0,
      fileDataLength: props.fileDataLength,
      columnLength: props.columnLength,
      dataList: props.dataList,
      well: props.wellList,
      wellValue: '',
      suggestions: [],
      plantList: [],
      plantValue: '',
      plantID: '',
      plantSuggestions: [],
      selected: null,
      selectedChange: this.selectRow,
      selectArray: [],
      selectArrayChange: this.selectArray,
      pageClick: this.pageClick,
      isBlocking: false,
      isBlockingChange: this.blockingChange,
      statusList: props.statusList,
      wellTypeID: props.wellTypeID,
      confirmDial: false,
      // slotID: props.slotID,
      slotVisibility: false,
      deleteDeadMaterialsConfirmBoxVisibility: false,

      cropSelected: props.cropSelected,
      breedingStation: props.breedingStation,
      breedingStationSelected: props.breedingStationSelected,

      slotName: props.slotName,
      slotID: props.slotID,
      moveKey: '',
      testsLookup: props.testsLookup,

      autoFetchTimer: 500, // 30000,

      importLevel: props.importLevel
    };
    this.watcher = null;
    autoBind(this);
  }
  componentDidMount() {
    window.addEventListener('beforeunload', this.handleWindowClose);
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
    this.props.pageTitle();

    // console.log('did mount plate filling');
    // const { pageSize } = this.state;

    if (this.props.breedingStation && this.props.breedingStation.length === 0) {
      // console.log('fetch');
      this.props.fetchBreeding();
    }
    if (this.props.statusList && this.props.statusList.length === 0) {
      // console.log('statusList');
      this.props.getStatusList();
    }
    if (this.props.wellTypeID && this.props.wellTypeID.length === 0) {
      // console.log('wellTypeID');
      this.props.getWelltypeID();
    }

    // fetch material type :: changes added
    if (this.props.materialTypeList.length === 0)
      this.props.fetch_materialType();
    if (this.props.materialStateList.length === 0)
      this.props.fetch_materialState();
    if (this.props.containerTypeList.length === 0)
      this.props.fetch_containerType();

    if (this.props.breedingStationSelected !== '' && this.props.cropSelected !== '') {
      // console.log('station and crop selected');
      const { breedingStationSelected, cropSelected } = this.props;
      this.props.fetch_testLookup(breedingStationSelected, cropSelected);
    }

    if (this.props.testID) {
      // console.log('Test selected = ', this.props.testID);
      this.props.fetch_well(this.props.testID);

      const obj = {
        testID: this.props.testID,
        pageNumber: this.props.pageNumber,
        pageSize:
          this.props.testTypeSelected.wellsPerPlate || this.props.pageSize,
        filter: this.props.filter
      };
      // console.log('componentDidMount', obj);
      this.props.plate_data(obj);
    }
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.importLevel !== this.props.importLevel) {
      // console.log(nextProps.importLevel, this.props.importLevel, ' --- ');
      this.setState({
        importLevel: nextProps.importLevel
      });
    }

    if (nextProps.testsLookup) {
      // console.log(nextProps.testsLookup, this.state.testsLookup);
      if (nextProps.testsLookup.length > 0 && nextProps.testID !== null) {
        // console.log(nextProps.fileList, this.props.fileList);
        const v = nextProps.testsLookup.filter(f => f.testID === nextProps.testID)[0];
        // console.log('v', v);
        if (v) {
          // console.log('next', nextProps.statusCode, nextProps);
          if (v.statusCode !== nextProps.statusCode) {
            // console.log('no match', v.statusCode, nextProps.statusCode);
            this.setState({
              statusCode: nextProps.statusCode
            });
          }
        }
        this.setState({
          testsLookup: nextProps.testsLookup
        });
      }
    }
    if (nextProps.statusCode !== this.props.statusCode) {
      // console.log(nextProps.statusCode, ' : nextPropt <> orios : ', this.props.statusCode);
      this.setState({
        statusCode: nextProps.statusCode
      });
      // console.log(nextProps.statusCode);
      // console.log('here');
      if (nextProps.statusCode === 200) {
        /**
         * TODO TEST AND REMOVE IT
         */
        // console.log(200, ' ----------------- ');
        // this.timerDummyRefreshFethTrigger();
        this.timerDummyRefreshFethTrigger();
      }
      /**
       * TODO in condtion success requres
       * clear timer for fetch
       * 150 request and sets to 200
       * when response come from lims 300 end timer
       */
      if (nextProps.statusCode !== 200) {
        clearInterval(this.watcher);
      }
    }
    if (nextProps.slotID !== this.props.slotID) {
      this.setState({ slotID: nextProps.slotID });
    }

    if (nextProps.cropSelected !== this.props.cropSelected) {
      this.setState({ cropSelected: nextProps.cropSelected });
      if (nextProps.breedingStationSelected !== '') {
        const { cropSelected, breedingStationSelected } = nextProps;
        // console.log(cropSelected, breedingStationSelected);
        this.props.fetch_testLookup(
          breedingStationSelected,
          cropSelected,
          true
        );
        this.props.fetchFileList(breedingStationSelected, cropSelected);
      }
    }
    if (
      nextProps.breedingStation.length !== this.props.breedingStation.length
    ) {
      this.setState({ breedingStation: nextProps.breedingStation });
    }
    if (
      nextProps.breedingStationSelected !== this.props.breedingStationSelected
    ) {
      this.setState({
        breedingStationSelected: nextProps.breedingStationSelected
      });
      if (nextProps.cropSelected !== '') {
        const { cropSelected, breedingStationSelected } = nextProps;
        // console.log(cropSelected, breedingStationSelected);

        this.props.fetch_testLookup(
          breedingStationSelected,
          cropSelected,
          true
        );
        this.props.fetchFileList(breedingStationSelected, cropSelected);
      }
    }

    if (nextProps.testTypeName !== this.props.testTypeName) {
      this.setState({ testTypeName: nextProps.testTypeName });
    }
    // test select from page it self ( display value )
    if (nextProps.testID !== this.props.testID) {
      this.setState({
        testID: nextProps.testID,
        testTypeID: nextProps.testTypeID,
        testTypeName: nextProps.testTypeName
      });
      this.props.fetchSlotList(nextProps.testID);
    }

    if (nextProps.fileDataLength !== this.props.fileDataLength) {
      this.setState({
        fileDataLength: nextProps.fileDataLength
      });
    }
    if (nextProps.columnLength !== this.props.columnLength) {
      this.setState({
        columnLength: nextProps.columnLength
      });
    }
    if (nextProps.dataList) {
      this.setState({
        dataList: nextProps.dataList
      });
    }
    if (nextProps.pageNumber !== this.props.pageNumber) {
      this.setState({
        pageNumber: nextProps.pageNumber
      });
    }
    if (nextProps.pageSize !== this.props.pageSize) {
      this.setState({
        pageSize: nextProps.pageSize
      });
    }
    if (nextProps.well) {
      this.setState({
        well: nextProps.well
      });
    }
    if (nextProps.plantList) {
      this.setState({
        plantList: nextProps.plantList,
        plantSuggestions: nextProps.plantList
      });
    }
    if (nextProps.statusList) {
      this.setState({
        statusList: nextProps.statusList
      });
    }
    if (nextProps.slotName !== this.props.slotName) {
      this.setState({
        slotName: nextProps.slotName
      });
    }
  }
  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.handleWindowClose);
    window.removeEventListener('resize', this.updateDimensions);
    clearInterval(this.watcher);
    // const { filter, testID, pageSize } = this.props;
    // this.props.pageClick({ testID, filter, pageSize, pageNumber: 1 });

    /**
     * Request that revisit to PlateFilling screen
     * always should open Page Number 1.
     */
    this.props.pagesizeForceChange(1);
  }
  onChangePlant = (event, { newValue }) => {
    this.setState({
      plantValue: newValue
    });
  };
  onWellChange = (event, { newValue }) => {
    this.setState({
      wellValue: newValue
    });
  };
  setIndexArray = index => {
    // alert(index);
    // alert('end');
    // index = null;
    if (index === null) {
      this.setState({
        selectArray: []
      });
    } else {
      this.setState({
        selectArray: index
      });
    }
  };
  updateDimensions = () => {
    const dim = getDim();
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  };
  handleWindowClose = e => {
    if (this.state.isBlocking) {
      e.returnValue = 'blocked';
    }
  };
  lookupChange = e => {
    const { value } = e.target;
    // alert(value);
    this.updateDimensions();
    if (value) {
      this.lookUpFetch(value, true);
    }
  };
  lookUpFetch(value, isLookUpChanged = false) {
    const testType = this.props.testsLookup.find(d => {
      if (d.testID === value * 1) {
        return d.testTypeName;
      }
      return null;
    });
    // console.log('lookUpFetch', testType);

    this.props.fetch_well(testType.testID);
    if (testType) {
      const obj = {
        testID: testType.testID,
        testTypeID: testType.testTypeID,
        testTypeName: testType.testTypeName,
        pageNumber: 1,
        pageSize: testType.wellsPerPlate,
        filter: []
      };
      this.props.plate_data(obj);
      this.blockingChange(false);
      this.setState({
        selected: -1, // -1 so that the table will get scrolled to top
        selectArray: []
      });
      // console.log(testType);
      this.props.selected_testLookup({
        testID: value,
        testName: testType.testName,
        testTypeID: testType.testTypeID,
        testTypeName: testType.testTypeName,
        remark: testType.remark,
        remarkRequired: testType.remarkRequired,
        statusCode: testType.statusCode,
        materialStateID: testType.materialStateID,
        materialTypeID: testType.materialTypeID,
        slotID: testType.slotID,
        wellsPerPlate: testType.wellsPerPlate,
        slotName: testType.slotName,
        platePlanName: testType.platePlanName,
        source: testType.source,
        importLevel: testType.importLevel,
      });
      if (isLookUpChanged) {
        this.props.homePageToOne();
      }
    }
  }
  // goToAssignMarker = () => {
  //   let red = true;
  //   if (this.state.isBlocking) {
  //     red = window.confirm('Changes you made may not be saved.'); // eslint-disable-line
  //   }
  //   if (red) {
  //     this.blockingChange(true);
  //     this.setState({
  //       goToAssignMarker: true
  //     });
  //   }
  // };
  fixColumn = e => {
    this.setState({
      fixColumn: e.target.value
    });
  };
  clearFilter = () => {
    const obj = {
      testID: this.state.testID,
      filter: [],
      pageNumber: 1,
      pageSize: this.props.pageSize
    };
    this.props.clearPlateFilter(obj);
  };
  selectRow = (rowIndex, shift, match, ctrl) => {
    // console.log(rowIndex, shift, match, ctrl);
    if (rowIndex === null) {
      return null;
    }
    const { selectArray, dataList } = this.state;

    if (ctrl) {
      if (!selectArray.includes(rowIndex)) {
        this.setIndexArray([...selectArray, rowIndex]);
      } else {
        const ind = selectArray.indexOf(rowIndex);
        const newSelect = [
          ...selectArray.slice(0, ind),
          ...selectArray.slice(ind + 1)
        ];
        if (newSelect.length === 0) {
          this.setState({ selected: null });
        }
        this.setIndexArray(newSelect);
      }
    } else if (shift) {
      const newShiftArray = this.state.selectArray;
      newShiftArray.push(rowIndex);
      // console.log(rowIndex, selected);
      newShiftArray.sort((a, b) => a - b);
      const preArray = [];
      for (
        let i = newShiftArray[0];
        i <= newShiftArray[newShiftArray.length - 1];
        i += 1
      ) {
        // console.log(dataList[i], i);
        if (!dataList[i].fixed) {
          preArray.push(i);
        }
        // if (!this.props.dataList[i].fixed) {
        //   preArray.push(i);
        // }
      }
      this.setIndexArray(preArray);
    } else {
      const checkSelect = selectArray.includes(rowIndex);
      if (checkSelect) {
        // const ind = selectArray.indexOf(rowIndex);
        // const newSelect = [
        //   ...selectArray.slice(0, ind),
        //   ...selectArray.slice(ind + 1)
        // ];
        this.setState({ selected: null });
        // if (newSelect.length === 0) {
        //   this.setState({ selected: null });
        // }
        // this.setIndexArray(newSelect);
        this.setIndexArray([]);
      } else {
        this.setState({ selected: rowIndex });
        this.setIndexArray([rowIndex]);
      }
    }
    return null;
  };
  toReservePlate = (statusCode, testID) => {
    const { remark, remarkRequired } = this.props;
    const { testTypeName } = this.state;

    if (remarkRequired && remark === '') {
      this.props.show_error({
        status: true,
        message: [
          `Please fill in Remark field. Specify a receiver for the ${testTypeName} test.`
        ],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
      return null;
    }

    this.props.testsLookup.map(test => {
      if (test.testID === testID) {
        if (!test.fixedPostionAssigned) {
          if (
            window.confirm('Fixed position not found. Are you sure you want to continue?') // eslint-disable-line
          ) {
            if (!checkStatus(statusCode, 'REQUESTED')) {
              this.props.reserveCall(testID);
            }
          }
        } else {
          this.props.reserveCall(testID);
        }
      }
      return null;
    });
    // TODO :: GET TEST DETAILL CALL until status code :: 300
    return null;
  };

  toReturn = status => {
    if (status) {
      this.props.sendToLims(this.state.testID);
    }
    this.setState({
      confirmDial: false
    });
  };
  toLims = e => {
    e.preventDefault();
    this.setState({
      confirmDial: true
    });
  };

  selectArray = index => {
    this.setIndexArray([index]);
  };
  pageClick = () => {
    this.setState({
      selected: -1
    });
  };
  blockingChange = status => {
    this.setState({
      isBlocking: status
    });
  };
  wellFetchRequested = ({ value }) => {
    this.setState({
      suggestions: wellSuggestions(value, this.state.well)
    });
  };
  wellClearRequested = () => {
    this.setState({
      suggestions: []
    });
  };

  testFetchRequested = ({ value }) => {
    const _this = this;
    const inputValue = value.trim().toLowerCase();
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      _this.final(inputValue);
    }, 500);
  };
  final = value => {
    this.props.fetch_plant({
      type: 'FETCH_PLANT',
      value,
      testID: this.state.testID
    });
  };
  testClearRequested = () => {
    this.setState({
      plantSuggestions: []
    });
  };
  testSuggestionValue = value => {
    const { materialID, materialKey } = value;
    this.setState({
      plantID: materialID
    });
    return materialKey;
  };
  testSuggestion = value => {
    const { materialKey } = value;
    return <div>{materialKey}</div>;
  };
  fixPlantPosition = () => {
    const { plantID, wellValue, importLevel } = this.state;
    // if import type is list, this function will return null
    if (importLevel && importLevel.toLowerCase() === 'list') {
      return null;
    }
    this.setState({
      plantID: '',
      plantValue: '',
      wellValue: ''
    });
    if (plantID !== '' && wellValue !== '') {
      this.props.assign_fix_position(this.state.testID, wellValue, plantID);
    } else {
      this.props.show_error({
        status: true,
        message: ['Please select Plant and Well before confirming.'],
        messageType: 2,
        notificationType: 1,
        code: ''
      });
    }
  };
  completeRequest = () => {
    if (this.state.isBlocking) {
      this.props.show_error({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please save your changes before completing request.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
      return;
    }
    const { completeRequest } = this.props;
    const { testID } = this.state;

    // TODO :: need to fix statusCode
    const statusCode = 400;
    completeRequest(testID, statusCode);
  };
  saveDbPlate = (testID, data) => {
    this.selectRow(null, false, true);
    this.setState({
      selected: null
    });
    this.selectArray(null);
    this.blockingChange(false);
    this.props.saveDbPlate(testID, data);
  };
  pagesizechange = pg => {
    this.props.pageSizechanged(pg);
    const obj = {
      testID: this.props.testID,
      pageNumber: 1,
      pageSize: pg,
      filter: this.props.filter
    };
    // CALLING PLATE DATA FETCH
    this.props.plate_data(obj);
  };
  handleDeadMaterialsDeletion = condition => {
    if (condition) {
      this.props.deleteDeadMaterialsCall(this.state.testID);
    }
    this.setState({
      deleteDeadMaterialsConfirmBoxVisibility: false
    });
  };
  deleteDeadMaterials = () => {
    if (this.state.isBlocking) {
      this.props.show_error({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please save your changes before deleting dead materials.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
    } else {
      this.setState({
        deleteDeadMaterialsConfirmBoxVisibility: true
      });
    }
  };

  toggleSlotVisibility() {
    this.setState({
      slotVisibility: !this.state.slotVisibility
    });
  }

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
  resetSelect = () => {
    this.setState({
      selected: null,
      selectArray: []
    });
  };

  timerDummyRefreshFethTrigger = () => {
    const { autoFetchTimer: time } = this.state;
    const _this = this;
    clearInterval(this.watcher);
    // console.log('trigger');
    /**
     * TODO :: 30 sec interval call fetching test data
     * change until it has any 200 status
     */
    this.watcher = setInterval(() => {
      // TODO remove
      console.log('timer fire');
      _this.dummyRefreshFethTrigger();
    }, time);
  };
  dummyRefreshFethTrigger = () => {
    const { breedingStationSelected, cropSelected } = this.props;
    // console.log('refresh call');
    this.props.fetch_testLookup(breedingStationSelected, cropSelected);
  };

  filterClearUI = () => {
    const { filter: filterLength } = this.props;
    if (filterLength < 1) return null;
    return (
      <button
        title="Clear Filter"
        className="with-i full-btn"
        onClick={this.clearFilter}
      >
        <i className="icon icon-cancel" />
        Clear filters
      </button>
    );
  };

  render() {
    const btnStat = checkStatus(this.state.statusCode, 'CONFIRM');
    if (this.state.goToAssignMarker) {
      return <Redirect to="/" />;
    }
    const {
      confirmDial,
      statusCode,
      fixColumn,
      testID,
      testTypeName,
      wellValue,
      suggestions,
      plantValue,
      plantSuggestions,
      slotVisibility,
      cropSelected,
      breedingStationSelected,
      slotID,
      importLevel
    } = this.state;
    const { platePlanName } = this.props;

    const testIsList = (importLevel && importLevel.toLowerCase() === 'list') ? true : false;
    // console.log('testIsList', testIsList, btnStat);
    // console.log('testIsList', testIsList, btnStat, 1);

    const inputProps = {
      placeholder: 'Select well',
      value: wellValue,
      onChange: this.onWellChange
    };
    const inputP = {
      placeholder: 'Select plant',
      value: plantValue,
      onChange: this.onChangePlant
    };
    const colRecords = this.state.columnLength;
    const { pageTitleText } = this.props;
    // console.log(this.props.slotList);

    let slotName = '';
    if (slotID !== '') {
      this.props.slotList.map(s => {
        if (s.slotID === slotID) {
          const { slotName: sname } = s;
          slotName = sname;
        }
        return null;
      });
    }
    const greaterthan200less300 = statusCode >= 300 && statusCode < 400;
    const testIDandlessOrEquals350 = testID && statusCode <= 350;
    const refreshButtonVisual = statusCode < 300 && statusCode >= 200;
    return (
      <div className="plateFilling">
        <section className="page-action">
          <div className="left">
            <div className="form-e">
              <label>Crops</label>
              <select
                name="corps"
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
                onChange={this.breedingStationSelectionFn}
                value={this.state.breedingStationSelected}
              >
                <option value="">Select</option>
                {this.state.breedingStation.map(breed => {
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
              <label>Test</label>
              <select value={testID || ''} onChange={this.lookupChange} className="w-200">
                <option value="">Select</option>
                {this.props.testsLookup.map(list => (
                  <option key={list.testID} value={list.testID}>
                    {list.testName}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-e">
              <label>TestType</label>
              <input
                type="text"
                value={testID ? testTypeName : ''}
                onChange={() => {}}
                disabled
              />
            </div>
          </div>
        </section>

        {testIDandlessOrEquals350 && (
          <section className="page-action">
            <div className="left">
              <div className="form-e">
                <label>Fixed position plant</label>
                <Autosuggest
                  suggestions={plantSuggestions}
                  onSuggestionsFetchRequested={this.testFetchRequested}
                  onSuggestionsClearRequested={this.testClearRequested}
                  getSuggestionValue={this.testSuggestionValue}
                  renderSuggestion={this.testSuggestion}
                  inputProps={inputP}
                />
              </div>
              <div className="form-e">
                <label>Position</label>
                <Autosuggest
                  suggestions={suggestions}
                  onSuggestionsFetchRequested={this.wellFetchRequested}
                  onSuggestionsClearRequested={this.wellClearRequested}
                  getSuggestionValue={wellSuggestionValue}
                  renderSuggestion={wellSuggestion}
                  inputProps={inputProps}
                />
              </div>
              <button
                title="Confirm position"
                disabled={testIsList || btnStat}
                onClick={this.fixPlantPosition}
                className="with-i"
              >
                <i className="icon icon-ok-circled" />
                Confirm position
              </button>
            </div>
          </section>
        )}

        <section
          className="page-action action1"
          style={{
            display: testID || pageTitleText === 'Punch List' ? 'flex' : 'none'
          }}
        >
          {/* 570px required clear btn, slot and plateplan */}
          <div className="left limit570">
            {this.filterClearUI()}
            {slotName !== '' && (
              <div className="form-e status-txt">
                <label className="full" title={slotName}>
                  Slot
                  {': '}
                  {slotName}
                </label>
              </div>
            )}
            {platePlanName && (
              <div className="form-e status-txt">
                <label className="full" title={platePlanName}>
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
            {statusCode <= 150 && (
              <button
                title="slot"
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
            {statusCode < 400 && (
              <button
                title="Save DB"
                className="with-i"
                disabled={btnStat || !this.state.isBlocking}
                onClick={() =>
                  this.saveDbPlate(this.state.testID, this.props.dataList)
                }
              >
                <i className="icon icon-database" />
                <span>Save DB</span>
              </button>
            )}
            {pageTitleText === 'Punch List' && (
              <Link to="platefilling" className="header Links">
                <i className="icon icon-left-open" />
                Back
              </Link>
            )}
            {statusCode === 150 && (
              <button
                title="Reserve Plate"
                className="with-i"
                onClick={e => {
                  e.preventDefault();
                  this.toReservePlate(statusCode, testID);
                }}
              >
                <i className="icon icon-clock" />
                <span>Reserve Plate</span>
              </button>
            )}
            {statusCode < 400 && (
              <button
                title="Remove Dead Materials"
                className="with-i"
                disabled={btnStat || testIsList}
                onClick={this.deleteDeadMaterials}
              >
                <i className="icon icon-trash" />
                <span>Dead Materials</span>
              </button>
            )}
            {greaterthan200less300 && (
              <button
                title="Complete Request"
                className="with-i"
                onClick={this.completeRequest}
              >
                <i className="icon icon-ok-circled" />
                <span>Complete Request</span>
              </button>
            )}
            {statusCode >= 300 && (
              <button
                title="Plate Label"
                className="with-i full-btn"
                onClick={e => {
                  e.preventDefault();
                  this.props.plateLabel(testID);
                }}
              >
                <i className="icon icon-print" />
                Plate <span>Label</span>
              </button>
            )}
            {(statusCode === 350 || statusCode === 300) && (
              <button
                title="Punch List"
                className="with-i full-btn"
                onClick={e => {
                  e.preventDefault();
                  this.props.history.push('/punchlist');
                }}
              >
                <i className="icon icon-print" />
                Punch <span>List</span>
              </button>
            )}
            {statusCode >= 400 && ( // PUNCH LIST OR SAMPLE LIST
              <button
                title="Sample List"
                className="with-i"
                onClick={e => {
                  e.preventDefault();
                  this.props.history.push('/samplelist');
                }}
              >
                <i className="icon icon-print" />
                <span>Sample List</span>
              </button>
            )}
            {statusCode === 400 && (
              <button title="To LIMS" className="with-i" onClick={this.toLims}>
                <i className="icon icon-paper-plane" />
                <span>TO LIMS</span>
              </button>
            )}
            {testID && (
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
            )}
            {refreshButtonVisual && (
              <button
                title="Refetch test"
                className="with-i no-text refresh"
                onClick={this.dummyRefreshFethTrigger}
              >
                <i className="icon icon-ccw" />
              </button>
            )}
          </div>
        </section>

        {confirmDial && (
          <ConfirmBox
            message="Before you send your final request to LIMS,
             FIRST verify with the LAB if your Plate Plan Request
             is already confirmed. Do you want to Continue?"
            click={this.toReturn}
          />
        )}
        {slotVisibility && (
          <Slot
            testID={this.state.testID}
            toggleVisibility={this.toggleSlotVisibility}
          />
        )}
        <Prompt
          message="Changes you made may not be saved."
          when={this.state.isBlocking}
        />
        {this.state.deleteDeadMaterialsConfirmBoxVisibility && (
          <ConfirmBox
            click={this.handleDeadMaterialsDeletion}
            message="Do you want to remove dead material from plates?"
          />
        )}

        <div className="container">
          <div className="trow">
            <div className="tc ell">
              <div>
                <div className="trow no-margn">
                  <div className="tcell text-right">
                    <div
                      className="toolBar"
                      style={{ display: colRecords > 0 ? '' : 'none' }}
                    >
                      {/* <button title="Save DB" className="clearFilterBtn icon"
                       disabled={btnStat || !this.state.isBlocking}
                       onClick={() =>
                       this.saveDbPlate(this.state.testID, this.props.dataList)
                       }>
                       <i className="icon icon-database"></i> <span>Save DB</span>
                       </button>
                       <button title="Complete Request" className="clearFilterBtn icon"
                       disabled={btnStat || !checkStatus(this.state.statusCode,"RESERVED")}
                       onClick={this.completeRequest}>
                       <i className="icon icon-ok-circled"></i> <span>Complete Request</span>
                       </button>
                       <button className="clearFilterBtn"
                       title="Goto Assign Marker"
                       onClick={this.goToAssignMarker}>Assign Marker
                       </button>
                       <button className="clearFilterBtn"
                       title="Remove Dead Materials"
                       disabled={btnStat}
                       onClick={this.deleteDeadMaterials}>Remove Dead Materials
                       </button> */}
                    </div>
                  </div>
                </div>
                {/*
                {this.state.dataList.length > 1 && (
                */}
                {testID && (
                  <TableData
                    {...this.state}
                    fixColumn={fixColumn}
                    resetSelect={() => this.resetSelect()}
                    breedingStationSelected={breedingStationSelected}
                    cropSelected={cropSelected}
                    importLevel={testIsList}
                  />
                )}
                {/* <Pagination
                 {...this.state}
                 /> */}
              </div>
            </div>
          </div>
          {testID && (
            <div className="paginationBody">
              <div>&nbsp;</div>
              <Page
                testID={this.props.testID}
                pageNumber={this.props.pageNumber}
                pageSize={this.props.pageSize}
                records={this.props.records}
                filter={this.props.filter}
                onPageClick={this.props.pageClick}
                isBlocking={this.state.isBlocking}
                isBlockingChange={this.state.isBlockingChange}
                pageClicked={this.state.pageClick}
                // resetSelect={() => alert('reset click')} // eslint-disable-line
                clearFilter={this.clearFilter}
                filterLength={this.props.filterLength}
                resetSelect={() => this.resetSelect()}
              />
              <div className="right">
                <Pagesize
                  pageSizeChange={this.pagesizechange}
                  pageSize={this.state.pageSize}
                  records={this.props.records}
                />
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }
}

PlateFillingComponent.defaultProps = {
  cropCode: null,
  fileID: null,
  testID: null,
  testTypeID: null,
  fileDataLength: null,
  statusCode: null,
  remarkRequired: null,
  wellList: null,
  tblCellWidth: 200,
  tblHeight: 400,
  tblWidth: 600,

  testTypeName: '',
  platePlanName: '',
  slotName: '',
  cropSelected: '',
  breedingStationSelected: '',
  crops: [],
  slotList: [],
  breedingStation: [],
  testTypeSelected: {},
  importLevel: 'PLT'
};
PlateFillingComponent.propTypes = {
  platePlanName: PropTypes.string,
  slotName: PropTypes.string,
  cropSelected: PropTypes.string,
  breedingStationSelected: PropTypes.string,
  crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  slotList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  breedingStation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  slotID: PropTypes.number.isRequired,
  testTypeSelected: PropTypes.object, // eslint-disable-line react/forbid-prop-types

  assign_fix_position: PropTypes.func.isRequired,
  breedingStationSelect: PropTypes.func.isRequired,
  cropSelect: PropTypes.func.isRequired,
  emptyRowColumns: PropTypes.func.isRequired,
  fetchSlotList: PropTypes.func.isRequired,
  fetchFileList: PropTypes.func.isRequired,
  newTestLoopupSelected: PropTypes.func.isRequired,
  fetchBreeding: PropTypes.func.isRequired,
  clearPlateFilter: PropTypes.func.isRequired,
  columnLength: PropTypes.number.isRequired,
  completeRequest: PropTypes.func.isRequired,
  containerTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  dataList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  deleteDeadMaterialsCall: PropTypes.func.isRequired,
  fetch_containerType: PropTypes.func.isRequired,
  fetch_fileList: PropTypes.func.isRequired,
  fetch_materialState: PropTypes.func.isRequired,
  fetch_materialType: PropTypes.func.isRequired,
  fetch_plant: PropTypes.func.isRequired,
  fetch_testLookup: PropTypes.func.isRequired,
  fetch_well: PropTypes.func.isRequired,
  fileList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  filterLength: PropTypes.number.isRequired,
  getStatusList: PropTypes.func.isRequired,
  getWelltypeID: PropTypes.func.isRequired,
  history: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  homePageToOne: PropTypes.func.isRequired,
  location: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  match: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  materialStateList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  materialTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  pageClick: PropTypes.func.isRequired,
  pageNumber: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  pageSizechanged: PropTypes.func.isRequired,
  pageTitle: PropTypes.func.isRequired,
  pageTitleText: PropTypes.string.isRequired,
  plantList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  plateLabel: PropTypes.func.isRequired,
  plate_data: PropTypes.func.isRequired,
  records: PropTypes.number.isRequired,
  remark: PropTypes.string.isRequired,
  remarkRequired: PropTypes.bool,
  reserveCall: PropTypes.func.isRequired,
  saveDbPlate: PropTypes.func.isRequired,
  selected_testLookup: PropTypes.func.isRequired,
  sendToLims: PropTypes.func.isRequired,
  showRemarks: PropTypes.func.isRequired,
  show_error: PropTypes.func.isRequired,
  sidemenu: PropTypes.func.isRequired,
  statusCode: PropTypes.number,
  statusList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  tblCellWidth: PropTypes.number,
  tblHeight: PropTypes.number,
  tblWidth: PropTypes.number,
  testID: PropTypes.number,
  testLookup: PropTypes.func.isRequired,
  testTypeID: PropTypes.number,
  fileID: PropTypes.number,
  fileDataLength: PropTypes.number,

  testTypeName: PropTypes.string,
  cropCode: PropTypes.string,
  testsLookup: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  well: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  wellTypeID: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  wellList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  importLevel: PropTypes.string,
};
export default PlateFillingComponent;
