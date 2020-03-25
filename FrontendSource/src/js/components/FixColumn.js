/**
 * Created by psindurakar on 12/14/2017.
 */
import React from 'react';
import PropTypes from 'prop-types';

const FixColumn = ({ _fixColumn, columnLength }) => {
  if (columnLength < 1) {
    return <span />;
  }
  return (
    <div className="fixColumn">
      <label>Fix Column</label> {/* eslint-disable-line */}
      <select onChange={_fixColumn}>
        <option value="0">none</option>
        <option value="1">1</option>
        <option value="2">2</option>
        <option value="3">3</option>
        <option value="4">4</option>
        <option value="5">5</option>
        <option value="6">6</option>
      </select>
    </div>
  );
};
FixColumn.defaultProps = {
  columnLength: null,
  _fixColumn: null
};
FixColumn.propTypes = {
  _fixColumn: PropTypes.func,
  columnLength: PropTypes.number
};
export default FixColumn;
