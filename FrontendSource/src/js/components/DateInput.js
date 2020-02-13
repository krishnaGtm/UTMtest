import React from 'react';
import PropTypes from 'prop-types';
import moment from 'moment';
moment().locale('en');
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';


const DateInput = props => (
  <div className="dateBox">
    <label>{props.label}</label> {/* eslint-disable-line */}
    <DatePicker
      name={props.name}
      disabled={props.disabled}
      selected={props.selected}
      minDate={props.todayDate}
      onChange={props.change}
      dateFormat={window.userContext.dateFormat}
      showWeekNumbers
      locale="en-gb"
    />
    <i className="icon icon-calendar-inv" />
  </div>
);
//showWeekNumbers
DateInput.defaultProps = {
  disabled: null
};
DateInput.propTypes = {
  label: PropTypes.string.isRequired,
  change: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
  // selected: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  todayDate: PropTypes.object.isRequired // eslint-disable-line react/forbid-prop-types
};
export default DateInput;
