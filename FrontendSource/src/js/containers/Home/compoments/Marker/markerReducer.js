/**
 * Created by psindurakar on 12/14/2017.
 */

const markerReducer = (state = [], action) => {
  switch (action.type) {
    case 'FETCH_MARKERLIST':
    case 'ASSIGN_MARKERLIST':
      return state;
    case 'MARKER_ADD':
      return [
        ...state,
        {
          determinationAlias: action.determinationAlias,
          determinationID: action.determinationID,
          determinationName: action.determinationName,
          selected: false
        }
      ];
    case 'MARKER_BULK_ADD':
      return action.data;
    case 'MARKER_TOGGLE':
      return state.map(marker => {
        if (marker.determinationID === action.determinationID) {
          return { ...marker, selected: !marker.selected };
        }
        return marker;
      });
    case 'MARKER_BLANK':
    case 'RESET_ASSIGN':
    case 'RESETALL':
      return [];
    case 'RESET_MARKER_LIST':
      return [];
    case 'MARKER_TO_FALSE':
      return state.map(marker => {
        if (marker.selected === true) {
          return { ...marker, selected: false };
        }
        return marker;
      });
    default:
      return state;
  }
};
export default markerReducer;
