/**
 * Created by psindurakar on 12/14/2017.
 */
const column = (state = [], action) => {
  switch (action.type) {
    case 'COLUMN_ADD':
      return [
        ...state,
        {
          columLabel: action.columLabel,
          columnNr: action.columnNr,
          dataType: action.dataType,
          isTraitColumn: action.isTraitColumn,
          traitID: action.traitID
        }
      ];
    case 'COLUMN_BULK_ADD':
      return action.data;
    case 'COLUMN_EMPTY':
    case 'RESET_ASSIGN':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default column;
