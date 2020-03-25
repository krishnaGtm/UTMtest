const move = (array, frm, to) => {
  const newArray = array.slice();
  const a1 = array[frm];
  const a2 = array[to];
  const obj1 = { ...a2, well: a1.well, wellID: a1.wellID, plate: a1.plate };
  const obj2 = { ...a1, well: a2.well, wellID: a2.wellID, plate: a2.plate };
  newArray.splice(frm, 1, obj1);
  newArray.splice(to, 1, obj2);
  return newArray;
};

const move2 = (data, itemsBeingMoved, moveIndex, direction) => {
  const notFixData = [];
  const fixData = [];
  const movingData = [];
  const remainData = [];
  const wellFixed = [];
  const newNotFixed = [];
  data.map((d, i) => {
    if (d.fixed === false) {
      notFixData.push({ ...d, no: i });
      if (itemsBeingMoved.includes(i)) {
        movingData.push({ ...d, no: i });
      } else {
        remainData.push({ ...d, no: i });
      }
    } else {
      fixData.push({ ...d, no: i });
    }
    return null;
  });
  remainData.map(d => {
    if (d.no === moveIndex * 1) {
      if (direction < 1) {
        for (let t = 0; t < movingData.length; t += 1) {
          newNotFixed.push(movingData[t]);
        }
        newNotFixed.push(d);
      } else {
        newNotFixed.push(d);
        for (let t = 0; t < movingData.length; t += 1) {
          newNotFixed.push(movingData[t]);
        }
      }
    } else {
      newNotFixed.push(d);
    }
    return null;
  });
  newNotFixed.map((d, i) => {
    wellFixed.push({
      ...d,
      well: notFixData[i].well,
      wellID: notFixData[i].wellID,
      plate: notFixData[i].plate
    });
    return null;
  });
  fixData.map(d => {
    wellFixed.splice(d.no, 0, d);
    return null;
  });
  return wellFixed;
};

const data = (state = [], action) => {
  switch (action.type) {
    case 'PLATEDATA_FETCH':
    case 'ACTION_SAVE_DB':
    case 'ASSIGN_FIX_POSITION':
    case 'REQUEST_RESERVE_PLATE':
    case 'REQUEST_DATA_DELETE':
    case 'REQUEST_TO_LIMS':
    case 'REQUEST_UNDO_DELETE':
      return state;
    case 'DATA_FILLING_BULK_ADD':
      return action.data;
    case 'DATA_ROW_MOVE':
      return move(state, action.frm, action.to);
    case 'DATA_ROW_DELETE':
      // console.log(action);
      // return state;
      return state.map(item => {
        // if (item.materialID === action.materialID) {
        if (action.wellIDs.includes(item.wellID)) {
          return { ...item, wellTypeID: action.wellTypeID, fixed: true };
        }
        return item;
      });
    case 'DATA_UNDO_DEAD':
      // console.log(action);
      return state.map(item => {
        // if (item.materialID === action.materialID) {
        if (action.wellIDs.includes(item.wellID)) {
          // console.log(item);
          return { ...item, wellTypeID: action.wellTypeID, fixed: false };
        }
        return item;
      });
    case 'DATA_REMOVE_REPLICA':
      return state.filter(item => item.wellID !== action.wellID);
    case 'DATA_BIG_MOVE': {
      const { moveIDs, id, direction } = action;
      return move2(state, moveIDs, id, direction);
    }
    case 'DATA_FILLING_EMPTY':
    case 'RESETALL':
      return [];
    default:
      return state;
  }
};
export default data;
