import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const HeaderCell = ({ value }) => (
  <Cell>
    <div className="headerCell">
      <span>{value}</span>
    </div>
  </Cell>
);
HeaderCell.propTypes = {
  value: PropTypes.string.isRequired
};
export default HeaderCell;
