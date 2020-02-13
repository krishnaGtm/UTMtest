/**
 * Created by psindurakar on 12/14/2017.
 */

const data = (state = [], action) => {
  switch (action.type) {
    case 'LAB_DATA_FETCH':
    case 'LAB_DATA_UPDATE':
      return state;

    case 'LAB_DATA_ADD':
      return action.data;

    case 'LAB_DATA_CHANGE': {
      const { index, value } = action;
      let { key } = action;
      if (typeof(key) === 'number') {
        key = key.toString();

        const update = state.map((cap, i) => {
          if (i === index) {
            // console.log(cap.key);
            cap[key] = value;
            return cap;
          }
          return cap;
        });
        return update;
      } else {
        const update2 = state.map((cap, i) => {
          if (i === index) {
            // console.log(cap);
            // console.log(cap[key]);
            const testKey = key.charAt(0).toLowerCase() + key.slice(1);
            cap[testKey] = value;
            return cap;
          }
          return cap;
        });
        return update2;
      }
    }
    case 'LAB_DATE_ROW_CHANGE': {
      // console.log(action);
      // { key, value } = action;
      let k = action.key;
      const v = action.value;
      // key = action.key;
      // value = action.value;

      k = k.toString();
      // console.log(action);
      const rowChange = state.map(cap => {
        // console.log(cap);
        const tk = k.charAt(0).toLowerCase() + k.slice(1)
        // cap[tk] = value;
        cap[tk] = parseInt(v);
        return cap;
      });
      return rowChange;
    }
    case 'LAB_DATA_EMPTY':
      return [];

    default:
      return state;
  }
};
export default data;
