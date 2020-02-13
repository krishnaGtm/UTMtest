import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import './pagesize.scss';

class Pagesize extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      pageSize: props.pageSize,
      records: props.records,
      wellsPerPlate: props.wellsPerPlate
    };
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.pageSize !== this.props.pageSize) {
      this.setState({ pageSize: nextProps.pageSize });
    }
    if (nextProps.records !== this.props.records) {
      this.setState({ records: nextProps.records });
    }
    if (nextProps.wellsPerPlate !== this.props.wellsPerPlate) {
      this.setState({ wellsPerPlate: nextProps.wellsPerPlate });
    }
  }
  onPageSize = e => {
    this.props.pageSizeChange(e.target.value * 1);
  };
  render() {
    const { records, wellsPerPlate } = this.state;
    if (records < 1) {
      return null;
    }
    return (
      <div className="pagesize_select">
        <label>Show per page </label> {/* eslint-disable-line */}
        <select onChange={this.onPageSize} value={this.state.pageSize}>
          <option value="200">200</option>
          <option value="400">400</option>
          <option value="800">800</option>
          <option value="1000">1000</option>
          {wellsPerPlate && <option value={wellsPerPlate}>Per Plate</option>}
          <option value={records}>all</option>
        </select>
      </div>
    );
  }
}
Pagesize.defaultProps = {
  wellsPerPlate: null
};
Pagesize.propTypes = {
  pageSize: PropTypes.number.isRequired,
  records: PropTypes.number.isRequired,
  pageSizeChange: PropTypes.func.isRequired,
  wellsPerPlate: PropTypes.number
};

const mapState = state => ({
  wellsPerPlate: state.plateFilling.total.wellsPerPlate
});

export default connect(mapState, null)(Pagesize);
