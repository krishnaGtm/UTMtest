const column = (state = [], action) => {
  switch (action.type) {
    case 'COLUMN_FILLING_ADD':
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
    case 'COLUMN_FILLING_BULK_ADD':
      return action.data;
    case 'COLUMN_FILLING_EMPTY':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default column;
