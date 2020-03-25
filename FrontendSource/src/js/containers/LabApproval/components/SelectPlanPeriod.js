/**
 * Created by sushanta on 3/29/18.
 */
import React from 'react';
import PropTypes from 'prop-types';

const SelectPlanPeriod = ({ onChange, planPeriods, selectedPeriodID }) => (
  <div className="form-e">
    <label>Plan period</label>
    <select onChange={onChange} className="w-300" value={selectedPeriodID}>
      <option value="0">Choose Plan Period</option>
      {planPeriods.map(period => (
        <option key={period.periodID} value={period.periodID}>
          {period.periodName}
        </option>
      ))}
    </select>
  </div>
);
SelectPlanPeriod.propTypes = {
  onChange: PropTypes.func.isRequired,
  planPeriods: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  selectedPeriodID: PropTypes.number.isRequired
};
export default SelectPlanPeriod;
