/**
 * Created by sushanta on 3/13/18.
 */
import React from 'react';
import PropTypes from 'prop-types';

const RowHead = ({ cols }) => {
  const indests = [];
  for (let i = 0; i <= cols; i += 1) {
    indests.push(
      <div key={i} className="indent">
        <div>{i || ''}</div>
      </div>
    );
  }
  return <div className="plateRow">{indests}</div>;
};

RowHead.propTypes = {
  cols: PropTypes.number.isRequired
};
export default RowHead;
