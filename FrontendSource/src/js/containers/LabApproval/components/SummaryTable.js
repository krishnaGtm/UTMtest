/**
 * Created by sushanta on 3/29/18.
 */
import React from 'react';
import PropTypes from 'prop-types';
import shortid from 'shortid';

const SummaryTable = ({ columnsName, keys, standardItem, currentItem, calWidth }) => (
  <div className="lab-approval-summary-table">
    <div className="lab-approval-period-name-container">
      <span>{standardItem.periodName}</span>
    </div>
    <div className="lab-approval-table">
      <table>
        <thead>
          <tr>
            <th />
            {columnsName}
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Standard</td>
            {keys.map(key => (
              <td
                key={shortid.generate()}
                style={{width:calWidth}}
              >
                {standardItem[key] || ''}
              </td>
            ))}
          </tr>
          <tr className="lab-approval-current-row">
            <td>Current</td>
            {keys.map(key => (
              <td
                key={shortid.generate()}
                style={{width:calWidth}}
              >
                {currentItem ? currentItem[key] || '' : ''}
              </td>
            ))}
          </tr>
        </tbody>
      </table>
    </div>
    <div className="lab-approval-comment-container">
      {standardItem.remark && <span>Comments: {standardItem.remark}</span>}
    </div>
  </div>
);
SummaryTable.defaultProps = {
  currentItem: null
};
SummaryTable.propTypes = {
  columnsName: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  keys: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  standardItem: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  currentItem: PropTypes.object // eslint-disable-line react/forbid-prop-types
};
export default SummaryTable;
