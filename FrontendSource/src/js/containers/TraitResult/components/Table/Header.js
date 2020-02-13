import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

class Header extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filter: props.filter || '',
      val: ''
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
    // if (nextProps.filter !== this.props.filter) {
    //   this.setState({
    //     filter: nextProps.filter
    //   });
    // }
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
      this.props.fetchFetch();
    }
  };

  filterOnChange = e => {
    const { target } = e;
    const { name, value } = target;
    const obj = {
      name,
      value,
      expression: 'contains',
      operator: 'and',
      dataType: 'NVARCHAR(255)'
    };
    this.props.addFilter(obj);
  };

  handle = key => {
    if (key === 'Action') return;
    if (key !== this.state.filter) {
      this.props.activeFilter(key);
    } else {
      this.props.activeFilter('');
    }
  };

  render() {
    const { val } = this.state;
    // console.log(this.props);
    // if (this.props.columnKey === this.state.filter) {
    //   console.log('yes filter');
    // }
    return (
      <div>
        <div className="headerCell">
          <span name={this.props.children}>{this.props.children}</span>
          {this.props.columnKey !== 'Action' && (
            <span className="filterBtn">
              <i
                role="presentation"
                className="icon-filter"
                onClick={() => this.handle(this.props.columnKey)}
              />
            </span>
          )}
        </div>

        {this.props.visibility && (
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

        {this.state.filter === this.props.columnKey && 1 === 2 && <div />}
      </div>
    );
  }
}

Header.defaultProps = {
  traitID: 0,
  visibility: false,
  filter: [],
  columnKey: '',
  activeFilter: () => {}
};
Header.propTypes = {
  traitID: PropTypes.number,
  visibility: PropTypes.bool,
  filter: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  activeFilter: PropTypes.func,
  addFilter: PropTypes.func.isRequired,
  fetchFetch: PropTypes.func.isRequired,
  columnKey: PropTypes.string,
  children: PropTypes.string.isRequired // eslint-disable-line react/forbid-prop-types
};
const mapProps = state => ({
  filter: state.traitResult.filter
});
const mapDispatch = dispatch => ({
  addFilter: obj => {
    dispatch({
      type: 'FILTER_TRAITRESULT_ADD',
      name: obj.name,
      value: obj.value,
      expression: 'contains',
      operator: 'and',
      dataType: obj.dataType,
      traitID: obj.traitID
    });
  },
  fetch_Filter_data: obj => {
    dispatch({
      type: 'FETCH_TRAITRESULT_FILTER_DATA',
      testID: obj.testID,
      testTypeID: obj.testTypeID,
      filter: obj.filter,
      pageNumber: obj.pageNumber,
      pageSize: obj.pageSize
    });
  }
});
export default connect(
  mapProps,
  mapDispatch
)(Header);
