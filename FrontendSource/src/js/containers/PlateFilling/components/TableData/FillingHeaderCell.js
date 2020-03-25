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
      const obj = {
        testID: this.props.testID,
        filter: this.props.filter,
        pageNumber: 1,
        pageSize: this.state.pageSize
      };
      this.props.fetch_FilterPlate_data(obj);
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
  columnKey: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  testID: PropTypes.number.isRequired,
  traitID: PropTypes.string,
  pageSize: PropTypes.number.isRequired,
  showFilter: PropTypes.func.isRequired,
  fetch_FilterPlate_data: PropTypes.func.isRequired,
  addFilter: PropTypes.func.isRequired,
  data: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};
const mapStateToProps = (state, ownProps) => ({
  filter: state.plateFilling.filter,
  fetchData: ownProps.fetchData
});
const mapDispatchToProps = dispatch => ({
  addFilter: obj => {
    const { name, value, dataType, traitID } = obj;
    dispatch({
      type: 'FILTER_PLATE_ADD',
      name,
      value,
      expression: 'contains',
      operator: 'and',
      dataType,
      traitID
    });
  },
  fetch_FilterPlate_data: obj => {
    dispatch({ ...obj, type: 'FETCH_PLATE_FILTER_DATA' });
  }
});
export default connect(mapStateToProps, mapDispatchToProps)(HeaderCell);
