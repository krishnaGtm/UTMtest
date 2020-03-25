/**
 * Created by sushanta on 3/14/18.
 */
const planPeriods = (state = [], action) => {
  switch (action.type) {
    case 'GET_PLAN_PERIODS_DONE':
      return action.data;
    default:
      return state;
  }
};
export default planPeriods;
