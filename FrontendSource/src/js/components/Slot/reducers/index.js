/**
 * Created by psindurakar on 12/14/2017.
 */
const slot = (state = [], action) => {
  switch (action.type) {
    case 'SLOT_ADD':
      // console.log(action);
      // console.log(action.data);
      return action.data.map(d =>
        Object.assign({}, d, {
          selected: d.slotID === action.slotID
        })
      );

    case 'SLOT_BULK_ADD':
      return action.data;
    case 'SLOT_EMPTY':
    case 'RESETALL':
      return [];
    case 'FETCH_SLOT':
    case 'UPDATE_SLOT_TEST_LINK':
    default:
      return state;
  }
};
export default slot;