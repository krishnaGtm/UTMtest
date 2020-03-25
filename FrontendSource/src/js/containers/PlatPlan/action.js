import {
  FETCH_PLAT_PLAN,
  FILTER_PLAT_PLAN_ADD,

  FILTER_PLAT_PLAN_RESET,
  PLAT_PLAN_BULK
} from './constant';

export const fetchPlatPlan = (pageNumber, pageSize, filter) => ({
  type: FETCH_PLAT_PLAN,
  pageNumber,
  pageSize,
  filter
});

// saga
export const filterPlatPlanClear = () => ({
  type: FILTER_PLAT_PLAN_RESET
});
export const filterPlatPlanAdd = obj => ({
  type: FILTER_PLAT_PLAN_ADD,
  name: obj.name,
  value: obj.value,
  expression: 'contains',
  operator: 'and',
  dataType: obj.dataType,
  traitID: obj.traitID
});
