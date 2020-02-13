const LAB_OVERVIEW_DATA_FETCH = 'LAB_OVERVIEW_DATA_FETCH';
const LAB_OVERVIEW_DATA_ADD = 'LAB_OVERVIEW_DATA_ADD';
const LAB_OVERVIEW_DATA_EMPTY = 'LAB_OVERVIEW_DATA_EMPTY';
// const LAB_OVERIVE_DATE_UPDATE = 'LAB_OVERIVE_DATE_UPDATE';

const data = (state = [], action) => {
  switch (action.type) {
    case LAB_OVERVIEW_DATA_FETCH:
      return state;

    case LAB_OVERVIEW_DATA_ADD:
      return action.data;

    case LAB_OVERVIEW_DATA_EMPTY:
      return [];

    default:
      return state;
  }
};
export default data;

// case LAB_OVERIVE_DATE_UPDATE:
//   // console.log(action);
//   return state.map(s => {
//     if (s.slotID === action.slotID) {
//       return {
//         ...s,
//         expectedDate: action.expectedDate,
//         planneDate: action.plannedDate
//       };
//       // s.expectedDate = action.expectedDate;
//       // s.planneDate = action.plannedDate;
//     }
//     return s;
//   });
