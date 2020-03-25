// constants
const FETCH_THREEGB = 'FETCH_THREEGB';
const FETCH_MATERIALS = 'FETCH_MATERIALS';
const ADD_MARKER_FILTER = 'ADD_MARKER_FILTER';
const UPDATE_TEST_ATTRIBUTES = 'UPDATE_TEST_ATTRIBUTES';
const FETCH_FILTERED_MATERIAL = 'FETCH_FILTERED_MATERIAL';
const TOGGLE_MATERIAL_MARKER = 'TOGGLE_MATERIAL_MARKER';
const SAVE_MATERIAL_MARKER = 'SAVE_MATERIAL_MARKER';
const TOGGLE_MARKER_OF_ALL_MATERIALS = 'TOGGLE_MARKER_OF_ALL_MATERIALS';
const RESET_MARKER_DIRTY = 'RESET_MARKER_DIRTY';
const SLOT_FETCH = 'FETCH_SLOT';
const SLOT_ADD = 'SLOT_ADD';
const TOGGLE_MARKER_OF_ALL_3GB_MATERIALS = 'TOGGLE_MARKER_OF_ALL_3GB_MATERIALS';
const SAVE_3GB_MATERIAL_MARKER = 'SAVE_3GB_MATERIAL_MARKER';
// action creators 3gb
export const fetchThreeGB = ({ testID, pageNumber, pageSize, filter }) => {
  return ({
    type: FETCH_THREEGB,
    testID,
    pageNumber,
    pageSize,
    filter
  });
}

// action creators
export const fetchMaterials = ({ testID, pageNumber, pageSize }) => ({
  type: FETCH_MATERIALS,
  testID,
  pageNumber,
  pageSize
});

export const updateTestAttributes = attributes => ({
  type: UPDATE_TEST_ATTRIBUTES,
  attributes
});

export const addMaterialFilter = filter => ({
  type: ADD_MARKER_FILTER,
  filter
});

export const fetchFilteredMaterial = options => ({
  type: FETCH_FILTERED_MATERIAL,
  ...options
});

export const toggleMaterialMarker = markerMaterialList => ({
  type: TOGGLE_MATERIAL_MARKER,
  markerMaterialList
});

export const saveMarkerMaterial = materialsMarkers => ({
  type: SAVE_MATERIAL_MARKER,
  materialsMarkers
});

export const toggleAllMarkers = (marker, checkedStatus) => ({
  type: TOGGLE_MARKER_OF_ALL_MATERIALS,
  marker,
  checkedStatus
});

export const save3GBMarkerMaterial = materialsMarkers => ({
  type: SAVE_3GB_MATERIAL_MARKER,
  materialsMarkers
});
export const toggleAll3GBMarkers = checkedStatus => ({
  type: TOGGLE_MARKER_OF_ALL_3GB_MATERIALS,
  checkedStatus
});

export const resetMarkerDirty = () => ({
  type: RESET_MARKER_DIRTY
});

export const slotFetch = testID => ({
  type: SLOT_FETCH,
  testID
});
export const slotAdd = (data, slotID) => ({ type: SLOT_ADD, data, slotID });
export const slotTestLink = (testID, slotID) => ({
  type: 'UPDATE_SLOT_TEST_LINK',
  testID,
  slotID
});
