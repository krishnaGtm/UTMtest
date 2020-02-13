import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

class HeaderCell extends React.Component {
  applyToRow = () => {
    const { click, view, keyValue } = this.props;
    const newKey = keyValue.charAt(0).toLowerCase() + keyValue.slice(1);
    click(view, newKey);
  };

  render() {
    const { keyValue } = this.props;
    if (keyValue === 'remark' || keyValue === 'periodID') {
      return <Cell className="headerCell">{this.props.view}</Cell>;
    }

    return (
      <Cell>
        <div className="headerCell">
          <span>{this.props.view}</span>
          <span className="filterBtn">
            <i
              role="presentation"
              className="icon-plus-squared"
              onClick={this.applyToRow}
            />
          </span>
        </div>
      </Cell>
    );
  }
}
HeaderCell.defaultProps = {
  view: '',
  keyValue: ''
};
HeaderCell.propTypes = {
  click: PropTypes.func.isRequired,
  view: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  keyValue: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
};
export default HeaderCell;
