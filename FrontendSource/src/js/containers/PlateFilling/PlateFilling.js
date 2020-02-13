import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';

import PlateFillingComponent from './components/PlateFillingComponent';

import { setPageTitle, sidemenuClose } from '../../action/index';
import { remarkShow } from '../../components/Remarks/remarkAction';

import './style.scss';
import {
  fetchWell,
  plateLabelRequest,
  reserveCall,
  sendToLims,
  deleteDeadMaterialsCall,
  pageSizeChange,
  filterClear,
  pageRecord,
  testsLookupConfirmRequest,
  saveDB,
  testsLookupSelected,
  rootSetAll,
  selectMaterialState,
  selectMaterialType,
  addSelectedCrop,
  fetchBreedingStation,
  breedingStationSelected,
  testslookupSelected,
  resetPlatefillingTotal,
  dataFillingEmpty,
  columnFillingEmpty,
  fetchSlot,
  filelistFetch,
  fetchTestlookup,
  assignFixPosition
} from './action';

const mapStateToProps = state => ({
  crops: state.user.crops,
  cropSelected: state.user.selectedCrop,
  breedingStation: state.breedingStation.station,
  breedingStationSelected: state.breedingStation.selected,

  slotID: state.rootTestID.slotID * 1,
  slotList: state.slot,
  fileList: state.assignMarker.file.filelist,
  testID: state.rootTestID.testID,
  testTypeID: state.rootTestID.testTypeID,
  statusCode: state.rootTestID.statusCode,
  remark: state.rootTestID.remark || '',
  remarkRequired: state.rootTestID.remarkRequired,
  pageTitleText: state.pageTitle,
  materialTypeList: state.materialType,
  materialStateList: state.materialState,
  containerTypeList: state.containerType,
  pageNumber: state.plateFilling.total.pageNumber,
  pageSize: state.plateFilling.total.pageSize,
  testsLookup: state.plateFilling.testsLookup.list,
  testTypeSelected: state.plateFilling.testsLookup.selected,
  testTypeName: state.plateFilling.testsLookup.selected.testTypeName,
  platePlanName: state.plateFilling.testsLookup.selected.platePlanName,
  columnLength: state.plateFilling.column.length,
  dataList: state.plateFilling.data,
  records: state.plateFilling.total.total,
  filter: state.plateFilling.filter,
  filterLength: state.plateFilling.filter.length,
  well: state.plateFilling.well,
  plantList: state.plateFilling.plant,
  statusList: state.statusList,
  wellTypeID: state.getWellTypeID,

  importLevel: state.rootTestID.importLevel,
});
const mapDispatchToProps = dispatch => ({
  cropSelect: crop => dispatch(addSelectedCrop(crop)),
  fetchBreeding: () => dispatch(fetchBreedingStation()),
  breedingStationSelect: selected => dispatch(breedingStationSelected(selected)),
  newTestLoopupSelected: obj => dispatch(testslookupSelected(obj)),

  emptyRowColumns: () => {
    dispatch(resetPlatefillingTotal());
    dispatch(dataFillingEmpty());
    dispatch(columnFillingEmpty());
  },

  fetchSlotList: testID => dispatch(fetchSlot(testID)),

  pageTitle: () => dispatch(setPageTitle('Plate Filling')),
  fetch_fileList: () => {
    dispatch({ type: 'FILELIST_FETCH' });
    // dispatch({ type: 'FETCH_TESTTYPE' });
  },
  getWelltypeID: () => dispatch({ type: 'FETCH_GETWELLTYPEID' }),
  getStatusList: () => dispatch({ type: 'FETCH_STATULSLIST' }),
  fetch_materialType: () => dispatch({ type: 'FETCH_MATERIAL_TYPE' }),
  fetch_materialState: () => dispatch({ type: 'FETCH_MATERIAL_STATE' }),
  fetch_containerType: () => dispatch({ type: 'FETCH_CONTAINER_TYPE' }),

  fetchFileList: (breeding, crop) => dispatch(filelistFetch(breeding, crop)),
  fetch_testLookup: (breedingStationCode, cropCode, freshFetch = false) => {
    dispatch(fetchTestlookup(breedingStationCode, cropCode));
    if (freshFetch) {
      // dispatch({ type: 'RESETALL_PLATEFILLING' });
    }
  },
  fetch_well: testID => dispatch(fetchWell(testID)),
  fetch_plant: obj => dispatch(obj),
  plate_data: obj => {
    if (obj.filter.length === 0) {
      dispatch({ type: 'FILTER_PLATE_CLEAR' });
    }
    dispatch({ ...obj, type: 'PLATEDATA_FETCH' });
  },
  selected_testLookup: testLookup => {
    // console.log(testLookup, 'PlateFilling.js');
    dispatch({ ...testLookup, type: 'TESTSLOOKUP_SELECTED' });
    dispatch(selectMaterialType(testLookup.materialTypeID));
    dispatch(selectMaterialState(testLookup.materialStateID));
    dispatch({
      type: 'ASSIGN_WELL_SIZE',
      wellsPerPlate: testLookup.wellsPerPlate
    });
    dispatch({
      type: 'SIZE_PLATE_RECORD',
      pageSize: testLookup.wellsPerPlate
    });
    // dispatch({
    //   type: 'ROOT_SET_ALL',
    //   testID: parseInt(testLookup.testID, 10),
    //   testTypeID: testLookup.testTypeID,
    //   statusCode: testLookup.statusCode,
    //   remark: testLookup.remark,
    //   remarkRequired: testLookup.remarkRequired,
    //   slotID: testLookup.slotID
    // });
    const {
      testID,
      testTypeID,
      statusCode,
      remark,
      remarkRequired,
      slotID,
      importLevel
    } = testLookup;
    const convTestID = parseInt(testID, 10);
    dispatch(rootSetAll(
      convTestID,
      testTypeID,
      statusCode,
      remark,
      remarkRequired,
      slotID,
      importLevel
    ));
  },
  sidemenu: () => dispatch(sidemenuClose()),
  assign_fix_position: (testID, wellPosition, materialID) => dispatch(assignFixPosition(testID, wellPosition, materialID)),
  clearPlateFilter: obj => dispatch({ ...obj, type: 'FETCH_CLEAR_PLATE_FILTER_DATA' }),
  testLookup: id => dispatch(testsLookupSelected(id)),
  saveDbPlate: (testID, data) => {
    const preData = [];
    data.map(d => {
      const obj = {
        materialID: d.materialID,
        wellID: d.wellID
      };
      preData.push(obj);
      return null;
    });
    dispatch(saveDB(testID, preData));
  },
  completeRequest: (testId, statusCode) => dispatch(testsLookupConfirmRequest(testId, statusCode)),
  show_error: obj => dispatch({ ...obj, type: 'NOTIFICATION_SHOW' }),
  pageClick: obj => dispatch({ ...obj, type: 'NEW_PLATE_PAGE' }),
  homePageToOne: () => {
    dispatch(pageRecord(1));
    dispatch(filterClear());
  },
  pageSizechanged: pg => dispatch(pageSizeChange(pg)),
  deleteDeadMaterialsCall: testID => dispatch(deleteDeadMaterialsCall(testID)),
  sendToLims: testID => dispatch(sendToLims(testID)),
  reserveCall: testID => dispatch(reserveCall(testID)),
  plateLabel: testID => dispatch(plateLabelRequest(testID)),
  showRemarks: () => dispatch(remarkShow()),
  /**
   * Request that revisit to PlateFilling screen
   * always should open Page Number 1.
   */
  pagesizeForceChange: pageNumber => dispatch({ type: 'PAGE_PLATE_RECORD', pageNumber })
});

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(PlateFillingComponent));
