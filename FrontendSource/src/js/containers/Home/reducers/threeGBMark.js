const initalState = {
  columns: [],
  tableData: [],
  totalRecords: 0,
  filters: [],
  markerMaterialMap: {},
  dirty: false
};

const threeGBmark = (state = initalState, action = {}) => {
  switch (action.type) {
    case 'FETCH_THREEGB_SUCCEEDED': {
      const { data, total: totalRecords } = action.materials;
      const { markerMaterialMap } = action;
      // console.log(data);
      return {
        ...state,
        columns: data.columns,
        tableData: data.data,
        totalRecords,
        markerMaterialMap
      };
    }
    case 'ADD_THREEGB_FILTER': {
      const filters = { ...state.filters };
      filters[action.filter.name] = action.filter;
      return { ...state, filters };
    }
    case 'TOGGLE_THREEGB': {
      const markerMaterialMap = { ...state.markerMaterialMap };
      action.markerMaterialList.forEach(marker => {
        markerMaterialMap[marker.key].newState = marker.value;
        markerMaterialMap[marker.key].changed =
          markerMaterialMap[marker.key].newState !==
          markerMaterialMap[marker.key].originalState;
      });
      const dirty = Object.keys(markerMaterialMap).some(key => markerMaterialMap[key].changed);
      return { ...state, markerMaterialMap, dirty };
    }
    case 'TOGGLE_ALL_THREEGB': {
      state.tableData.forEach(material => {
        const key = `${material.materialID}-${marker}`;
        markerMaterialMap[key] = {
          ...markerMaterialMap[key],
          newState: checkedStatus,
          changed: markerMaterialMap[key].originalState !== checkedStatus
        };
      });
      const dirty = Object.keys(markerMaterialMap).some(key => markerMaterialMap[key].changed);
      return { ...state, markerMaterialMap, dirty };
    }
    case 'THREEGB_SAVE_SUCCEEDED': {
      const markerMaterialMap = { ...state.markerMaterialMap };
      Object.keys(markerMaterialMap).forEach(key => {
        markerMaterialMap[key] = {
          ...markerMaterialMap[key],
          changed: false,
          originalState: markerMaterialMap[key].newState
        };
      });
      return { ...state, markerMaterialMap, dirty: false };
    }
    case 'RESET_THREEGB_DIRTY': {
      const markerMaterialMap = { ...state.markerMaterialMap };
      Object.keys(markerMaterialMap).forEach(key => {
        markerMaterialMap[key] = {
          ...markerMaterialMap[key],
          changed: false,
          newState: markerMaterialMap[key].originalState
        };
      });
      return { ...state, dirty: false, markerMaterialMap };
    }
    default:
      return state;
  }
};
export default threeGBmark;
