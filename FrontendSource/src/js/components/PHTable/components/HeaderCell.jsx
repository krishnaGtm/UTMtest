import React from 'react';
import PropTypes from 'prop-types';
// import { connect } from 'react-redux';
// import PropTypes from 'prop-types';
// import { Cell } from 'fixed-data-table-2';

class HeaderCell extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      // value: props.filterValue || '',
      columnKey: props.columnKey,

      // filter: props.filter || '',
      val: ''
    };
  }
  componentDidMount() {
    // console.log('filterValue', this.state.filterValue);
    this.props.filter.map(field => {
      const matchName = this.props.columnKey;
      console.log(this.props.columnKey, matchName);
      if (field.name === matchName) {
        this.setState({
          val: field.value || ''
        });
      }
      return null;
    });
  }
  componentWillReceiveProps(nextProps) {
    nextProps.filter.map(field => {
      const matchName = this.props.columnKey;
      if (field.name === matchName) {
        this.setState({
          val: field.value
        });
      }
      return null;
    });
    if (nextProps.filter.length === 0) {
      this.setState({
        val: ''
      });
    }
  }

  onFilterEnter = e => {
    if (e.key === 'Enter') {
      // console.log('enter');
      this.props.filterFetch();
    }
  };

  filterOnChange = e => {
    const { target } = e;
    const { name, value } = target;
    // console.log(target, name, value);
    this.setState({
      val: value
    });
    const obj = {
      name,
      value,
      expression: 'contains',
      operator: 'and',
      dataType: 'NVARCHAR(255)'
    };
    this.props.filterAdd(obj);
  };

  render() {
    const { value, columnKey, val } = this.state;
    return (
      <div>
        <div className="headerCell">
          <span>{value.name}</span>
          {value.filter && (
            <span className="filterBtn">
              <i
                role="presentation"
                className="icon-filter"
                onClick={() => this.props.handle(columnKey)}
              />
            </span>
          )}
        </div>
        {value.filter && (
          <div className="filterBox">
            <input
              name={this.props.columnKey}
              type="text"
              value={val}
              onChange={this.filterOnChange}
              onKeyPress={this.onFilterEnter}
            />
          </div>
        )}
      </div>
    );
  }
}

HeaderCell.defaultProps = {
  columnKey: ''
};
HeaderCell.propTypes = {
  // value: PropTypes.string.isRequired
  value: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  filterAdd: PropTypes.func.isRequired,
  filterFetch: PropTypes.func.isRequired,
  handle: PropTypes.func.isRequired,
  columnKey: PropTypes.string
};

export default HeaderCell;
