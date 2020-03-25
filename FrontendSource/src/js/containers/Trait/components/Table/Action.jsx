import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const ActionCell = props => {
  const { relation, rowIndex, onRemove, onUpdate } = props;
  const { relationID, traitID } = relation[rowIndex];

  return (
    <Cell>
      <i
        role="button"
        tabIndex={0}
        className="icon icon-pencil"
        onKeyPress={() => {}}
        onClick={() => onUpdate(traitID)}
      />
      {relationID !== 0 && (
        <i
          role="button"
          tabIndex={0}
          className="icon icon-cancel"
          onKeyPress={() => {}}
          onClick={() => onRemove(relationID)}
        />
      )}
    </Cell>
  );
};
ActionCell.defaultProps = {
  relation: [],
  rowIndex: 0
};
ActionCell.propTypes = {
  relation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  rowIndex: PropTypes.number,
  onUpdate: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired // eslint-disable-line react/forbid-prop-types
};
export default ActionCell;
