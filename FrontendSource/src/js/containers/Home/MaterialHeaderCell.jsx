import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Cell } from 'fixed-data-table-2';
import PropTypes from 'prop-types';
import autoBind from 'auto-bind';
import {
  addMaterialFilter,
  fetchFilteredMaterial,
  toggleAllMarkers,
  toggleAll3GBMarkers
} from '../Home/actions';

class MaterialHeaderCellComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      children: props.columnKey,
      columnKey: props.sort, // eslint-disable-line
      data: props.data, // eslint-disable-line
      val: '',
      traitID: props.traitID, // eslint-disable-line
      pageNumber: props.pageNumber, // eslint-disable-line
      pageSize: props.pageSize,
      determinationMarkerChecked: false
    };
    autoBind(this);
  }
  componentDidMount() {
    const { filters } = this.props;
    const key = this.props.traitID || this.props.columnKey;
    const val = filters[key] ? filters[key].value : '';
    this.setState({ val }); // eslint-disable-line
  }
  componentWillReceiveProps(nextProps) {
    const { filters } = nextProps;
    const key = this.props.traitID || this.props.columnKey;
    const val = filters[key] ? filters[key].value : '';
    this.setState({ val });
    if (nextProps.pageNumber !== this.props.pageNumber) {
      this.setState({
        pageNumber: nextProps.pageNumber // eslint-disable-line
      });
    }
    if (nextProps.pageSize !== this.props.pageSize) {
      this.setState({
        pageSize: nextProps.pageSize
      });
    }
  }

  _filter() {
    this.props.showFilter();
  }
  _filterOnChange(e) {
    const filterName = this.props.data.traitID || this.props.data.columnLabel;
    const obj = {
      name: filterName,
      value: e.target.value,
      expression: 'contains',
      operator: 'and',
      dataType: this.props.data.dataType
    };
    this.props.addFilter(obj);
  }

  _onFilterEnter(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      const filter = Object.keys(this.props.filters).map(key => this.props.filters[key]);
      const obj = {
        fileID: this.props.testID,
        filter,
        pageNumber: 1,
        pageSize: this.state.pageSize
      };
      this.props.fetchFilteredMaterial(obj);
    }
  }
  toggleAllMarkers(e) {
    const determinationMarkerChecked = e.target.checked;
    this.setState({
      determinationMarkerChecked
    });

    const lowerTraidId = this.state.traitID.toLowerCase();
    this.props.toggleAllMarkers(lowerTraidId, determinationMarkerChecked);
  }
  toggleAll3GBMark(e) {
    const determinationMarkerChecked = e.target.checked;
    this.setState({
      determinationMarkerChecked
    });
    this.props.toggleAll3GB(determinationMarkerChecked);
  }

  render() {
    const { traitID } = this.props;
    const statusDisabled = this.props.statusCode >= 400;
    const { children } = this.state;
    if (children === 'To3GB') {
      return (
        <div>
          <div className="headerCell">
            <div className="check-all-marker tableCheck">
              <input
                id="alltoggle3gb"
                type="checkbox"
                disabled={statusDisabled}
                checked={this.state.determinationMarkerChecked}
                onChange={this.toggleAll3GBMark}
              />
              <label htmlFor={`alltoggle3gb`} /> {/* eslint-disable-line */}
            </div>
            <span name={children}>{this.props.label}</span>
          </div>
        </div>
      );
    }

    return (
      <div title={this.props.label}>
        <div className="headerCell">
          {traitID &&
            traitID.toString().substring(0, 2) === 'D_' &&
            statusDisabled !== true && (
              <div className="check-all-marker tableCheck">
                <input
                  id={traitID}
                  type="checkbox"
                  disabled={statusDisabled}
                  checked={this.state.determinationMarkerChecked}
                  onChange={this.toggleAllMarkers}
                />
                <label htmlFor={traitID} /> {/* eslint-disable-line */}
              </div>
            )}
          <span name={children}>{this.props.label}</span>
          {/*
          <span
            className="filterBtn"
            onClick={this._filter}
            role="button"
            onKeyDown={() => {}}
            tabIndex="0"
          >
            <i className="icon-filter" />
          </span>
          */}
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

const mapStateToProps = state => ({
  testID: state.assignMarker.file.selected.testID,
  testTypeID: state.assignMarker.testType.selected,
  filters: state.assignMarker.materials.filters,
  statusCode: state.rootTestID.statusCode
});

const mapDispatchToProps = dispatch => ({
  addFilter: obj => dispatch(addMaterialFilter(obj)),
  fetchFilteredMaterial: obj => dispatch(fetchFilteredMaterial(obj)),
  toggleAllMarkers: (marker, checkedStatus) =>
    dispatch(toggleAllMarkers(marker, checkedStatus)),
  toggleAll3GB: checkedStatus => dispatch(toggleAll3GBMarkers(checkedStatus))
});

MaterialHeaderCellComponent.defaultProps = {
  columnKey: '',
  label: '',
  filters: []
};

MaterialHeaderCellComponent.propTypes = {
  toggleAll3GB: PropTypes.func.isRequired,
  showFilter: PropTypes.func.isRequired,
  fetchFilteredMaterial: PropTypes.func.isRequired,
  addFilter: PropTypes.func.isRequired,
  testID: PropTypes.number.isRequired,
  data: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  columnKey: PropTypes.string,
  pageNumber: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  filters: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  toggleAllMarkers: PropTypes.func.isRequired,
  label: PropTypes.string,
  statusCode: PropTypes.number.isRequired
};

const MaterialHeaderCell = connect(mapStateToProps, mapDispatchToProps)(MaterialHeaderCellComponent);
export default MaterialHeaderCell;
