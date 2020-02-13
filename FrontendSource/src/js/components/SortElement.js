import React from 'react';
import PropTypes from 'prop-types';

const SortElement = props => {
  const { data } = props;
  return (
    <span className="sortEle">
      {' '}
      {data.field}
      <i
        className="icon icon-cancel"
        role="button"
        tabIndex="0"
        onKeyDown={() => {}}
        onClick={() => {
          props.removeSort(data.field);
        }}
      />
    </span>
  );
};
SortElement.propTypes = {
  data: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  removeSort: PropTypes.func.isRequired
};
export default SortElement;
