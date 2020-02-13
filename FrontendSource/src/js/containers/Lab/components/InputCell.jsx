import React from 'react';
import PropTypes from 'prop-types';
import { Cell } from 'fixed-data-table-2';

class InputCell extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      inputDisplay: false
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.isChanged !== true) {
      // console.log(nextProps);
      this.setState({ inputDisplay: false });
    }
  }

  change = e => {
    const { rowIndex, change, arrayKey, data } = this.props;
    // console.log(e.target.name, e.target.value);
    // console.log('inputCell change()', rowIndex, arrayKey);
    const { periodID } = data[rowIndex];
    const testKey = arrayKey.charAt(0).toLowerCase() + arrayKey.slice(1);

    switch (e.target.name) {
      case 'number':
        if (e.target.value > -1) {
          change(rowIndex, testKey, e.target.value, periodID);
        }
        break;
      case 'text':
        change(rowIndex, testKey, e.target.value, periodID);
        break;
      default:
    }
  };

  click = () => {
    this.setState({ inputDisplay: true });
  };

  render() {
    const { rowIndex, data, arrayKey } = this.props;
    const { inputDisplay } = this.state;

    if (arrayKey === 'periodID') {
      const period = data[rowIndex];
      return <Cell>{period.periodName}</Cell>;
    }

    let display = '';
    if (data[rowIndex][arrayKey] !== null) {
      const testKey = arrayKey.charAt(0).toLowerCase() + arrayKey.slice(1);
      display = data[rowIndex][testKey] || '';
    }
    if (arrayKey === 'remark') {
      return (
        <Cell>
          <input
            type="text"
            name="text"
            value={display}
            onClick={this.click}
            onChange={this.change}
            readOnly={!inputDisplay}
          />
        </Cell>
      );
    }
    return (
      <Cell>
        <input
          key="rowIndex"
          type="number"
          name="number"
          value={display}
          onChange={this.change}
          readOnly={!inputDisplay}
          onClick={this.click}
        />
      </Cell>
    );
  }
}
InputCell.defaultProps = {
  data: [],
  arrayKey: '',
  rowIndex: 0
};
InputCell.propTypes = {
  change: PropTypes.func.isRequired,
  rowIndex: PropTypes.number,
  data: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  arrayKey: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  isChanged: PropTypes.bool.isRequired
};
export default InputCell;
