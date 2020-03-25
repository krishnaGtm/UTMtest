import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const BreederAction = props => {
  // console.log(props);
  const { ids, onRemove, onUpdate } = props;
  // const { slotID, slotName } = data;
  // console.log(slotID, slotName);
  // console.log(data);
      // {slotName}
  return (
    <Cell>
      {/*<i
        role="button"
        tabIndex={0}
        title="Edit"
        className="icon icon-pencil"
        onKeyPress={() => {}}
        onClick={() => onUpdate(ids)}
      />*/}
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

BreederAction.defaultProps = {
  data: {}
};
// data: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
BreederAction.propTypes = {
  data: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  onRemove: PropTypes.func.isRequired,
  onUpdate: PropTypes.func.isRequired
};
/* ActionCell.propTypes = {
  relation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // activeFilter: PropTypes.func.isRequired,
  rowIndex: PropTypes.number,
  onUpdate: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired // eslint-disable-line react/forbid-prop-types
}; */
export default BreederAction;
