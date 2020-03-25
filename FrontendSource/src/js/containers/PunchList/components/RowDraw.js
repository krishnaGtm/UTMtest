/**
 * Created by sushanta on 3/13/18.
 */
import React from 'react';
import PropTypes from 'prop-types';

const RowDraw = ({ rows, cols }) => {
  const rowDraw = [];
  for (let i = -1; i < cols; i += 1) {
    if (i < 0) {
      rowDraw.push(<div>{rows.rowID}</div>);
    } else {
      const style = {
        background: rows.cells[i].bgColor,
        color: rows.cells[i].fgColor,
        position: 'relative'
      };
      rowDraw.push(
        <div style={style}>
          {rows.cells[i].materialKey}
          {rows.cells[i].broken && (
            <span className="brokenItemIcon">
              <i className="icon icon-info-circled" />
            </span>
          )}
        </div>
      );
    }
  }
  return (
    <div className="plateRow">
      {rowDraw.map((d, i) => (
        <div key={i}> {/*eslint-disable-line*/}
          {d}
        </div>
      ))}
    </div>
  );
};

RowDraw.propTypes = {
  rows: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  cols: PropTypes.number.isRequired
};

export default RowDraw;
