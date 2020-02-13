import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

class HeaderCell extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      children: props.columnKey,
      data: props.data,
      val: '',
      pageSize: props.pageSize
    };
  }
  componentDidMount() {
    this.props.filter.map(field => {
      const matchName = this.props.traitID || this.props.columnKey;
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
      const matchName = this.props.traitID || this.props.columnKey;
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
    if (nextProps.pageSize !== this.props.pageSize) {
      this.setState({
        pageSize: nextProps.pageSize
      });
    }
  }

  _filter = () => {
    this.props.showFilter();
  };
  _filterOnChange = e => {
    const obj = {
      name: this.state.data.traitID || e.target.name,
      value: e.target.value,
      expression: 'contains',
      operator: 'and',
      dataType: this.state.data.dataType
    };
    this.props.addFilter(obj);
  };
  _onFilterEnter = e => {
    if (e.key === 'Enter') {
      e.preventDefault();
      // RESET MARKERS
      this.props.resetMarkers();
      // FETCH FILTER DATA
      const obj = {
        testID: this.props.testID,
        testTypeID: this.props.testTypeID,
        filter: this.props.filter,
        pageNumber: 1,
        pageSize: this.state.pageSize
      };
      this.props.fetch_Filter_data(obj);
    }
  };

  render() {
    const { children } = this.state;
    return (
      <div>
        <div className="headerCell">
          <span name={children}>{this.props.label}</span>
          <span className="filterBtn">
            <i className="icon-filter" onClick={this._filter} /> {/*eslint-disable-line*/}
          </span>
        </div>
        <div className="filterBox">
          <input
            type="text"
            name={this.props.columnKey}
            ref={this.props.columnKey}
            value={this.state.val}
            onChange={this._filterOnChange}
            onKeyPress={this._onFilterEnter}
          />
        </div>
      </div>
    );
  }
}
HeaderCell.defaultProps = {
  traitID: null
};
HeaderCell.propTypes = {
  columnKey: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
    .isRequired,
  label: PropTypes.string.isRequired,
  testID: PropTypes.number.isRequired,
  testTypeID: PropTypes.number.isRequired,
  traitID: PropTypes.number,
  pageSize: PropTypes.number.isRequired,
  showFilter: PropTypes.func.isRequired,
  fetch_Filter_data: PropTypes.func.isRequired,
  resetMarkers: PropTypes.func.isRequired,
  addFilter: PropTypes.func.isRequired,
  data: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};
const mapStateToProps = state => ({
  testID: state.assignMarker.file.selected.testID,
  testTypeID: state.assignMarker.testType.selected,
  filter: state.assignMarker.filter
});
const mapDispatchToProps = dispatch => ({
  addFilter: obj => {
    dispatch({
      type: 'FILTER_ADD',
      name: obj.name,
      value: obj.value,
      expression: 'contains',
      operator: 'and',
      dataType: obj.dataType,
      traitID: obj.traitID
    });
  },
  resetMarkers: () => {
    dispatch({
      type: 'MARKER_TO_FALSE'
    });
  },
  fetch_Filter_data: obj => {
    dispatch({
      type: 'FETCH_FILTERED_DATA',
      testID: obj.testID,
      testTypeID: obj.testTypeID,
      filter: obj.filter,
      pageNumber: obj.pageNumber,
      pageSize: obj.pageSize
    });
  }
});
export default connect(mapStateToProps, mapDispatchToProps)(HeaderCell);
