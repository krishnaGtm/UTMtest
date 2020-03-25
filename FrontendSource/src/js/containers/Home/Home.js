import { connect } from 'react-redux';

import { sidemenuClose } from '../../action/index';
import { remarkShow } from '../../components/Remarks/remarkAction';

import HomeComponent from './compoments/HomeComponent.jsx';
import {
  fetchThreeGB,
  fetchMaterials,
  updateTestAttributes,
  resetMarkerDirty
} from './actions';
import './Home.scss';

const mapStateToProps = state => ({
  cumulate: state.assignMarker.file.selected.cumulate,
  // token: state.user.token,
  sources: state.sources.list,
  sourceSelected: state.sources.selected,
  selectedFileSource: state.assignMarker.file.selected.source,

  crops: state.user.crops,
  cropSelected: state.user.selectedCrop,
  breedingStation: state.breedingStation.station,
  breedingStationSelected: state.breedingStation.selected,

  fileList: state.assignMarker.file.filelist,
  testTypeList: state.assignMarker.testType.list,
  materialTypeList: state.materialType,
  materialStateList: state.materialState,
  containerTypeList: state.containerType,
  importLevel: state.rootTestID.importLevel,
  testID: state.rootTestID.testID,
  slotID: state.rootTestID.slotID,
  slotList: state.slot,
  rootTestTypeID: state.rootTestID.testTypeID,
  fileID: state.assignMarker.file.selected.fileID,
  testTypeID: state.rootTestID.testTypeID,
  isolated: state.assignMarker.file.selected.isolated,
  plannedDate: state.assignMarker.file.selected.plannedDate,
  expectedDate: state.assignMarker.file.selected.expectedDate,
  platePlanName: state.assignMarker.file.selected.platePlanName,
  cropCode: state.assignMarker.file.selected.cropCode,
  pageSize: state.assignMarker.total.pageSize,
  pageNumber: state.assignMarker.total.pageNumber,
  markerstatus: !!state.assignMarker.marker.length,
  fileDataLength: state.assignMarker.total.total,
  columnLength: state.assignMarker.column.length,
  records: state.assignMarker.total.total,
  filter: state.assignMarker.filter,
  filterLength: state.assignMarker.filter.length,
  markerStateList: state.assignMarker.marker,
  statusList: state.statusList,
  statusCode: state.rootTestID.statusCode,
  dirty: state.assignMarker.materials.dirty,
  warningFlag: state.phenome.warningFlag,
  warningMessage: state.phenome.warningMessage,
  importPhemoneExisting: state.phenome.existingImport,
});
const mapDispatchToProps = dispatch => ({
  fetchMaterialDeterminationsForExternalTest: options =>
    dispatch({ type: 'FETCH_MATERIAL_EXTERNAL', ...options }),
  sendTOThreeGBCockPit: (testID, filter) =>
    dispatch({ type: 'THREEGB_SEND_COCKPIT', testID, filter }),
  fetchToken: () => dispatch({ type: 'FETCH_TOKEN' }),
  cropSelect: crop => dispatch({ type: 'ADD_SELECTED_CROP', crop }),
  fetchBreeding: () => dispatch({ type: 'FETCH_BREEDING_STATION'}),
  breedingStationSelect: selected =>
    dispatch({ type: 'BREEDING_STATION_SELECTED', selected }),
  emptyRowColumns: () => {
    dispatch({ type: 'RESETALL_PLATEFILLING' });
    dispatch({ type: 'RESET_ASSIGNMARKER_TOTAL' });
    dispatch({ type: 'DATA_BULK_ADD', data: [] });
    dispatch({ type: 'COLUMN_BULK_ADD', data: [] });
  },
  fetchSlotList: testID => dispatch({ type: 'FETCH_SLOT', testID }),
  pageTitle: () => {
    dispatch({
      type: 'SET_PAGETITLE',
      title: 'Assign Markers'
    });
  },
  sidemenu: () => dispatch(sidemenuClose()),
  checkToken: () => {
    // dispatch({type: 'FETCH_TOKEN'})
  },
  getStatusList: () => dispatch({ type: 'FETCH_STATULSLIST' }),

  fetch_testLookup: (breedingStationCode, cropCode) => {
    dispatch({
      type: 'FETCH_TESTLOOKUP',
      breedingStationCode,
      cropCode
    });
  },
  fetchFileList: (breeding, crop) =>
    dispatch({ type: 'FILELIST_FETCH', breeding, crop }),
  fetchTestType: () => dispatch({ type: 'FETCH_TESTTYPE', testTypeID: ''}),
  fetchMaterialType: () => dispatch({ type: 'FETCH_MATERIAL_TYPE' }),
  fetchMaterialState: () => dispatch({ type: 'FETCH_MATERIAL_STATE' }),
  fetchContainerType: () => dispatch({ type: 'FETCH_CONTAINER_TYPE' }),

  selectFile: selectedFile => {
    dispatch({ type: 'FILELIST_SELECTED', file: selectedFile });
    dispatch({
      type: 'SELECT_MATERIAL_TYPE',
      id: selectedFile.materialTypeID
    });
    dispatch({
      type: 'SELECT_MATERIAL_STATE',
      id: selectedFile.materialstateID
    });
    dispatch({
      type: 'SELECT_CONTAINER_TYPE',
      id: selectedFile.containerTypeID
    });
    dispatch({
      type: 'CHANGE_PLANNED_DATE',
      plannedDate: selectedFile.plannedDate
    });
    // console.log(selectedFile);
    dispatch({
      type: 'ROOT_SET_ALL',
      testID: selectedFile.testID,
      testTypeID: selectedFile.testTypeID,
      remark: selectedFile.remark || '',
      statusCode: selectedFile.statusCode,
      remarkRequired: selectedFile.remarkRequired,
      slotID: selectedFile.slotID,
      importLevel: selectedFile.importLevel
    });
  },
  assignData: (selectedFile, filechange = false) => {
    // console.log(selectedFile, 'Home.js');
    if (filechange) {
      dispatch({ type: 'FILTER_CLEAR' });
      dispatch({ type: 'FILTER_PLATE_CLEAR' });
      dispatch({ type: 'PAGE_PLATE_RECORD', pageNumber: 1 });
    }
    dispatch({
      type: 'ASSIGNDATA_FETCH',
      file: { ...selectedFile, filter: [], pageNumber: 1 }
    });

    // fort selected plate filling
    dispatch({
      type: 'TESTSLOOKUP_SELECTED',
      ...selectedFile
    });
    // console.log(selectedFile, 'selectedFile');
    dispatch({
      type: 'ASSIGN_WELL_SIZE',
      wellsPerPlate: selectedFile.wellsPerPlate || 92
    })
  },
  clearFilterFetch: obj => {
    dispatch({
      type: 'FETCH_CLEAR_FILTER_DATA',
      testID: obj.testID,
      testTypeID: obj.testTypeID,
      filter: obj.filter,
      pageNumber: obj.pageNumber,
      pageSize: obj.pageSize
    });
    dispatch({ type: 'MARKER_TO_FALSE' });
  },
  pageClick: obj => dispatch({ ...obj, type: 'NEW_PAGE' }),
  showRemarks: () => dispatch(remarkShow()),
  fetchMaterials: options => dispatch(fetchMaterials(options)),
  showError: obj => dispatch(obj),
  updateTestAttributes: attributes => dispatch(updateTestAttributes(attributes)),
  resetMarkerDirty: () => dispatch(resetMarkerDirty()),
  addToThreeGB: (testID, filter) => {
    dispatch({
      type: 'ADD_TO_THREEGB',
      testID,
      filter
    });
  },
  fetchThreeGBMark: options => dispatch(fetchThreeGB(options)),
  fetchImportSource: () => dispatch({ type: 'FETCH_IMPORTSOURCE' }),
  ImportSourceChange: source => dispatch({ type: 'CHANGE_IMPORTSOURCE', source }),
  deleteTest: testID => dispatch({ type: 'POST_DELETE_TEST', testID }),
  existingImportFunc: flag => dispatch({ type: 'PHENOME_EXISTING_IMPORT', flag })
});

const Home = connect(
  mapStateToProps,
  mapDispatchToProps
)(HomeComponent);
export default Home;
