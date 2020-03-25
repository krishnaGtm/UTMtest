export function markerToggle(id) {
  return {
    type: 'MARKER_TOGGLE',
    determinationID: id
  };
}

export function markerAssign(testID, testTypeID, filter, determinations) {
  return {
    type: 'ASSIGN_MARKERLIST',
    testID,
    testTypeID,
    filter,
    determinations
  };
}
