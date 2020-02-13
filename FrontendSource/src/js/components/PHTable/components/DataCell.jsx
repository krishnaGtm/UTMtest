import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const Datacell = ({ value, rowIndex, selectArray }) => {
  const newStyle = {};
  const isCellHighlighted = true;
  if (selectArray) {
    if (selectArray.includes(rowIndex)) {
      newStyle.background = isCellHighlighted ? '#8bce3f' : '';
      newStyle.color = isCellHighlighted ? '#000' : '';
      // console.log(props);
    }
  }

  return (
    <Cell title={value} style={newStyle}>
      {value}
    </Cell>
  );
};
Datacell.defaultProps = {
  value: ''
};
Datacell.propTypes = {
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
};
export default Datacell;
