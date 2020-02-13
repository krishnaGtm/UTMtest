export function remarkHide() {
  return {
    type: 'REMARKS_HIDE'
  };
}

export function remarkShow() {
  return {
    type: 'REMARKS_SHOW'
  };
}

export function remarkSave(testID, remark) {
  return {
    type: 'ROOT_SET_REMARK',
    testID,
    remark
  };
}
