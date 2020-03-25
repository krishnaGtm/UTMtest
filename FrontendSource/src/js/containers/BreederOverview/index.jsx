import { connect } from 'react-redux';
import BreederOverviewComponent from './components/BreaderOverviewComponent';

import { slotFetch, addFilter, clearFilter, addSelectedCrop, fetchBreedingStation, breedingStationSelected } from './action';

const mapStatus = state => ({
  crops: state.user.crops,
  cropSelected: state.user.selectedCrop,
  breedingStation: state.breedingStation.station,
  breedingStationSelected: state.breedingStation.selected,

  sideMenu: state.sidemenuReducer,
  slotList: state.slotBreeder.slot || [],
  total: state.slotBreeder.total.total,
  pagenumber: state.slotBreeder.total.pageNumber,
  pagesize: state.slotBreeder.total.pageSize,
  filter: state.slotBreeder.filter
});
const mapDispatch = dispatch => ({
  cropSelect: crop => dispatch(addSelectedCrop(crop)),
  fetchBreeding: () => dispatch(fetchBreedingStation()),
  breederSlotPageReset: () => {
    dispatch({ type: 'BREEDER_SLOT_PAGE_RESET' });
  },
  breedingStationSelect: selected =>
    dispatch(breedingStationSelected(selected)),
  fetchSlot: (cropCode, brStationCode, pageNumber, pageSize, filter) =>
    dispatch(slotFetch(cropCode, brStationCode, pageNumber, pageSize, filter)),
  filterClear: () => dispatch(clearFilter()),
  filterAdd: obj => {
    const { name, value, dataType, traitID } = obj;
    const CONSTAINS = 'contains';
    const OPT = 'and';
    dispatch(addFilter(name, value, CONSTAINS, OPT, dataType, traitID));
  }
});

export default connect(mapStatus, mapDispatch)(BreederOverviewComponent);
