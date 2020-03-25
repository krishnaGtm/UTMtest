/**
 * Created by sushanta on 3/14/18.
 */

export const getApprovalList = periodID => ({
  type: 'GET_APPROVAL_LIST',
  periodID
});

export const getApprovalListDone = data => ({
  type: 'GET_APPROVAL_LIST_DONE',
  data
});

export const getPlanPeriods = () => ({
  type: 'GET_PLAN_PERIODS'
});

export const getPlanPeriodsDone = data => ({
  type: 'GET_PLAN_PERIODS_DONE',
  data
});

export const approveSlot = (slotID, selectedPeriodID) => ({
  type: 'APPROVE_SLOT',
  slotID,
  selectedPeriodID
});

export const denySlot = (slotID, selectedPeriodID) => ({
  type: 'DENY_SLOT',
  slotID,
  selectedPeriodID
});

export const updateSlotPeriod = (
  slotID,
  periodID,
  plannedDate,
  expectedDate
) => ({
  type: 'UPDATE_SLOT_PERIOD',
  slotID,
  periodID,
  plannedDate,
  expectedDate
});
