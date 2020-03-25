const SLOT_FETCH = 'FETCH_SLOT';
const SLOT_ADD = 'SLOT_ADD';
const SLOT_DELETE = 'SLOT_DELETE';

export const slotFetch = (testID) => ({
  type: SLOT_FETCH,
  testID
});
export const slotAdd = (data, slotID) => ({ type: SLOT_ADD, data, slotID });
export const slotTestLink = (testID, slotID) => ({
  type: 'UPDATE_SLOT_TEST_LINK',
  testID,
  slotID
});

export const slotDeleteAction = (slotID, cropCode, brStationCode, slotName) => ({
  type: SLOT_DELETE,
  slotID,
  cropCode,
  brStationCode,
  slotName
 });