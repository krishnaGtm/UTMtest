import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

const RelationAction = props => {
  // console.log(props);
  const { data, onRemove, onUpdate } = props;
  const { relationID, traitID } = data;
  // console.log(relationID, traitID);
  // console.log(data);
  // return (
  //   <Cell>hello</Cell>
  // );
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

RelationAction.defaultProps = {
  data: {}
};
// data: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
RelationAction.propTypes = {
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
export default RelationAction;
