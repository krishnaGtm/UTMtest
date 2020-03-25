import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const MailAction = props => {
  // console.log(props);
  const { data, onAdd, onRemove, onUpdate, ids } = props;
  // const { relationID, id, cropCode } = data;
  return (
    <Cell>
      <i
        role="button"
        tabIndex={0}
        title="Copy"
        className="icon icon-plus-squared"
        onKeyPress={() => {}}
        onClick={() => onAdd(ids)}
      />
      <i
        role="button"
        tabIndex={0}
        title="Edit"
        className="icon icon-pencil"
        onKeyPress={() => {}}
        onClick={() => onUpdate(ids)}
      />
        <i
          role="button"
          tabIndex={0}
          title="Delete"
          className="icon icon-cancel"
          onKeyPress={() => {}}
          onClick={() => onRemove(ids)}
        />

    </Cell>
  );
};
MailAction.defaultProps = {
  // relation: [],
  // rowIndex: 0
  data: {},
  ids: 0
};
MailAction.propTypes = {
  data: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  // activeFilter: PropTypes.func.isRequired,
  ids: PropTypes.number,
  onAdd: PropTypes.func.isRequired,
  onUpdate: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired // eslint-disable-line react/forbid-prop-types
};
export default MailAction;
