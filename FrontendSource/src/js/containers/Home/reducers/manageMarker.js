// Materials / Marker management
const initalState = {
  columns: [],
  tableData: [],
  totalRecords: 0,
  filters: [],
  markerMaterialMap: {},
  dirty: false,
  numberOfSample:[]
};

const materials = (state = initalState, action = {}) => {
  switch (action.type) {
    case 'FETCH_MATERIALS_SUCCEEDED': {
      const { data, total: totalRecords } = action.materials;
      const { markerMaterialMap } = action;
      return {
        ...state,
        columns: data.columns,
        tableData: data.data,
        totalRecords,
        markerMaterialMap
      };
    }
    case 'ADD_MARKER_FILTER': {
      const filters = { ...state.filters };
      filters[action.filter.name] = action.filter;
      return { ...state, filters };
    }
    case 'TOGGLE_MATERIAL_MARKER': {
      const markerMaterialMap = { ...state.markerMaterialMap };
      action.markerMaterialList.forEach(marker => {
        // console.log(marker);
        markerMaterialMap[marker.key].newState = marker.value;
        markerMaterialMap[marker.key].changed =
          markerMaterialMap[marker.key].newState !==
          markerMaterialMap[marker.key].originalState;
      });
      const dirty = Object.keys(markerMaterialMap).some(key => markerMaterialMap[key].changed);
      return { ...state, markerMaterialMap, dirty };
    }
    case 'TOGGLE_MARKER_OF_ALL_MATERIALS': {
      const markerMaterialMap = { ...state.markerMaterialMap };
      const { marker, checkedStatus } = action;
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
    case 'MATERIALS_MARKER_SAVE_SUCCEEDED': {
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
    case 'RESET_MARKER_DIRTY': {
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

    case 'TOGGLE_MARKER_OF_ALL_3GB_MATERIALS': {
      const markerMaterialMap = { ...state.markerMaterialMap };
      const { checkedStatus } = action;
      state.tableData.forEach(material => {
        const key = `${material.materialKey}-d_To3GB`;
        // const key = `${material.materialKey}-d_Selected`;
        markerMaterialMap[key] = {
          ...markerMaterialMap[key],
          newState: checkedStatus,
          changed: markerMaterialMap[key].originalState !== checkedStatus
        };
      });
      const dirty = Object.keys(markerMaterialMap).some(key => markerMaterialMap[key].changed);
      return { ...state, markerMaterialMap, dirty };

      // console.log(markerMaterialMap);
      // console.log(action);
      // return state;
    }
    default:
      return state;
  }
};

const initSampleNumber = {
  samples:  [],
  dirty: false,
  refresh: false
}
export const numberOfSamples = (state = initSampleNumber, action = {}) => {
  switch (action.type) {
    case 'SAMPLE_NUMBER': {
      return {...state, samples: action.samples};
      // return action.samples;
    }
    case 'SAMPLE_NUMBER_CHANGE': {
      const { samples } = state;
      // console.log(action, samples);
      const newSample = samples.map(row => {
        if (row.materialID === action.materialID) {
          // console.log(row);
          return {
            ...row,
            nrOfSample: action.nrOfSample * 1,
            changed: true,
          };
        }
        return row;
      });
      return {...state, samples: newSample, dirty: true, refresh: !state.refresh};
      /*
      return state.map(row => {
        if (row.materialID === action.materialID) {
          console.log(row);
          return {...row, nrOfSample: action.nrOfSample * 1, changed: true};
        }
        return row
      });*/
      // return state;
    }
    case 'SAMPLE_NUMBER_CHANGE_FALSE': {
      const { samples } = state;
      const newSample = samples.map(row => {
        // console.log(row);
        // return Object.assign({}, row, { changed: false });
        return {...row, changed: false, };
      });
      return {...state, samples: newSample, dirty: false, refresh: !state.refresh};
    }
    case 'SAMPLE_NUMBER_REST':
      return initSampleNumber;
    default:
      return state;
  }
};
// export numberOfSamples;
export default materials;
