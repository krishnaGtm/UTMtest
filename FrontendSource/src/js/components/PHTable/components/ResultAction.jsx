import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const ResultAction = props => {
  // console.log(props);
  const { data, onRemove, onUpdate, ids } = props;
  const { relationID, id, cropCode } = data;
  return (
    <Cell>
      <i
        role="button"
        tabIndex={0}
        className="icon icon-pencil"
        onKeyPress={() => {}}
        onClick={() => onUpdate(ids)}
      />
      {relationID !== 0 && (
        <i
          role="button"
          tabIndex={0}
          className="icon icon-cancel"
          onKeyPress={() => {}}
          onClick={() => onRemove(id, cropCode)}
        />
      )}
    </Cell>
  );
};
ResultAction.defaultProps = {
  // relation: [],
  // rowIndex: 0
  data: {},
  ids: 0
};
ResultAction.propTypes = {
  data: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  // activeFilter: PropTypes.func.isRequired,
  ids: PropTypes.number,
  onUpdate: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired // eslint-disable-line react/forbid-prop-types
};
export default ResultAction;
