import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
// import { Cell } from 'fixed-data-table-2';

class HeaderCell extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      columnKey: props.columnKey,
      // filter: props.filter,
      val: ''
    };
  }
  componentDidMount() {
    this.props.filter.map(field => {
      const matchName = this.props.columnKey;
      if (field.name === matchName) {
        this.setState({
          val: field.value
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
    // this.setState({
    //   val: value
    // });
    const obj = {
      name,
      value,
      expression: 'contains',
      operator: 'and',
      dataType: 'NVARCHAR(255)'
    };
    this.props.addFilter(obj);
  };

  render() {
    const { value, columnKey, val } = this.state;
    return (
      <div>
        <div className="headerCell">
          <span>{value}</span>
          <span className="filterBtn">
            <i
              role="presentation"
              className="icon-filter"
              onClick={() => this.props.handle(columnKey)}
            />
          </span>
        </div>
        <div className="filterBox">
          <input
            name={this.props.columnKey}
            type="text"
            value={val}
            onChange={this.filterOnChange}
            onKeyPress={this.onFilterEnter}
          />
        </div>
      </div>
    );
  }
}
HeaderCell.defaultProps = {
  columnKey: '',
  filter: ''
};
HeaderCell.propTypes = {
  columnKey: PropTypes.string,
  filter: PropTypes.string,
  value: PropTypes.string.isRequired,
  addFilter: PropTypes.func.isRequired,
  handle: PropTypes.func.isRequired,
  filterFetch: PropTypes.func.isRequired
};

const mapProps = state => ({
  filter: state.slotBreeder.filter
});
const mapDispatch = dispatch => ({
  addFilter: obj => {
    dispatch({
      type: 'FILTER_BREEDER_SLOT_ADD',
      name: obj.name,
      value: obj.value,
      expression: 'contains',
      operator: 'and',
      dataType: obj.dataType,
      traitID: obj.traitID
    });
  }
  // fetch_Filter_data: obj => {
  //   dispatch({
  //     type: 'FETCH_FILTERED_DATA',
  //     testID: obj.testID,
  //     testTypeID: obj.testTypeID,
  //     filter: obj.filter,
  //     pageNumber: obj.pageNumber,
  //     pageSize: obj.pageSize
  //   });
  // }
});

export default connect(mapProps, mapDispatch)(HeaderCell);
