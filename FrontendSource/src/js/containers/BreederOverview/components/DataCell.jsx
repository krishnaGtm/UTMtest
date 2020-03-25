import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const Datacell = ({ value }) => <Cell>{value}</Cell>;
Datacell.defaultProps = {
  value: ''
};
Datacell.propTypes = {
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
};
export default Datacell;
