import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const ActionCell = props => {
  // console.log(props);
  const { rowIndex, onRemove, onUpdate } = props;
  // result
  // const { traitDeterminationResultID } = result[rowIndex];
  // console.log(traitDeterminationResultID, '*************');
  const traitDeterminationResultID = rowIndex;
  return (
    <Cell>
      <i
        role="button"
        tabIndex={0}
        className="icon icon-pencil"
        onKeyPress={() => {}}
        onClick={() => onUpdate(traitDeterminationResultID)}
      />
      <i
        role="button"
        tabIndex={0}
        className="icon icon-cancel"
        onKeyPress={() => {}}
        onClick={() => onRemove(traitDeterminationResultID)}
      />
    </Cell>
  );
};
ActionCell.defaultProps = {
  // result: [],
  rowIndex: 0
};
ActionCell.propTypes = {
  // result: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // activeFilter: PropTypes.func.isRequired,
  rowIndex: PropTypes.number,
  onUpdate: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired // eslint-disable-line react/forbid-prop-types
};
export default ActionCell;
