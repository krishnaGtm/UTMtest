/**
 * Created by psindurakar on 12/14/2017.
 */
const LAB_COLUMN_ADD = 'LAB_COLUMN_ADD';
const LAB_COLUMN_EMPTY = 'LAB_COLUMN_EMPTY';

const column = (state = [], action) => {
  switch (action.type) {
    case LAB_COLUMN_ADD: {
      const newColumn = [];
      newColumn.push({
        testProtocolID: 'periodID',
        testProtocolName: 'Period Name'
      });

      return newColumn.concat(action.data).concat([
        {
          testProtocolID: 'remark',
          testProtocolName: 'Remarks'
        }
      ]);
    }
    case LAB_COLUMN_EMPTY: {
      return [];
    }
    default:
      return state;
  }
};
export default column;
