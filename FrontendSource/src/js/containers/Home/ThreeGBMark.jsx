import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Table, Column } from 'fixed-data-table-2';
import PropTypes from 'prop-types';
import autoBind from 'auto-bind';

import Page from '../../components/Page/Page';
import MaterialCell from './MaterialCell';
import MaterialHeaderCell from './MaterialHeaderCell';
import { toggleMaterialMarker, save3GBMarkerMaterial } from './actions';
// component
class ThreeGBMarkTableComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      columnWidths: {},
      fixColumn: props.fixColumn || 1,
      headerHeight: 40,
      rowHeight: 36,
      pageNumber: props.pageNumber || 1,
      pageSize: props.pageSize || 150,
      tblCellWidth: props.tblCellWidth || 150,
      tblWidth: props.tblWidth || 1000,
      tblHeight: props.tblHeight || 300,
      sortedColumns: ['', '', ''] // THREE VALUES ARE RESERVED FOR THREE FIRST COLUMNS Crop, GID, Plantnr
    };
    this._onColumnResizeEndCallback = this._onColumnResizeEndCallback.bind(this);
    autoBind(this);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.materials.materials !== this.props.materials.materials) {
      // console.log(nextProps.materials.dirty);
    }
    if (nextProps.materials.columns.length) {
      this.sortColumns(nextProps.materials.columns);
    }
    if (nextProps.tblWidth !== this.props.tblWidth) {
      this.setState({
        tblWidth: nextProps.tblWidth
      });
    }
    if (nextProps.tblHeight !== this.props.tblHeight) {
      this.setState({
        tblHeight: nextProps.tblHeight
      });
    }
  }

  onPageClick = pg => {
    this.setState({
      pageNumber: pg
    });
  };

  save3GBMarkerMaterial() {
    const { materials, testID } = this.props;
    const { markerMaterialMap } = materials;
    const materialWithMarker = [];
    Object.keys(markerMaterialMap).forEach(key => {
      if (markerMaterialMap[key].changed) {
        const map = key.split('-');
        materialWithMarker.push({
          materialKey: map[0],
          selected: !!markerMaterialMap[key].newState
        });
      }
    });
    const materialsMarkers = {
      testID,
      materialWithMarker
    };
    this.props.saveMarkerMaterial(materialsMarkers);
  }

  saveMarkerMaterial33() {
    const { materials, testTypeID, testID } = this.props;
    const { markerMaterialMap } = materials;
    const materialWithMarker = [];
    Object.keys(markerMaterialMap).forEach(key => {
      if (markerMaterialMap[key].changed) {
        const map = key.split('-');
        materialWithMarker.push({
          materialID: map[0],
          determinationID: map[1].split('_')[1],
          selected: !!markerMaterialMap[key].newState
        });
      }
    });

    const materialsMarkers = {
      testTypeID,
      testID,
      materialWithMarker
    };
    this.props.saveMarkerMaterial(materialsMarkers);
  }

  toggleMaterialMarker(markerMaterialList) {
    this.props.toggleMaterialMarker(markerMaterialList);
  }

  _filter() {
    const hh = this.state.headerHeight;
    this.setState({
      headerHeight: hh === 40 ? 90 : 40
    });
  }

  // sould sort column in order of  Crop, GID, Platnr and rest of columns
  sortColumns(columns) {
    // 2017 Aug 01
    // TODO :: @krishna is providing fixed = 1
    // need to manage fix column from backedn
    // const sortedColumns = ['', '', ''];
    const sortedColumns = ['']; // THREE VALUES ARE RESERVED FOR THREE FIRST COLUMNS Crop, GID, Plantnr
    columns.forEach(col => {
      switch (col.columnLabel) {
        // case 'Crop': {
        //   sortedColumns[0] = col;
        //   break;
        // }
        case 'GID': {
          sortedColumns[0] = col;

          break;
        }
        // case 'Plantnr': {
        //   sortedColumns[2] = col;
        //
        //   break;
        // }
        default: {
          sortedColumns.push(col);
          break;
        }
      }
    });
    this.setState({ sortedColumns });
  }

  _onColumnResizeEndCallback(newColumnWidth, columnKey) {
    this.setState(({ columnWidths }) => ({
      columnWidths: {
        ...columnWidths,
        [columnKey]: newColumnWidth
      }
    }));
  }

  _fixColumn = () => {
    // console.log('-fixCol');
  };

  clearFilter = () => {
    // console.log('clearFilter');
  };

  render() {
    const {
      tblCellWidth,
      fixColumn,
      columnWidths,
      headerHeight,
      rowHeight,
      sortedColumns
    } = this.state;
    const { materials } = this.props;

    // flag for disabling save button in case of marker status is unchanged.
    const markerStatusChanged = Object.keys(materials.markerMaterialMap).some(key => materials.markerMaterialMap[key].changed);

    let { tblWidth, tblHeight } = this.state;

    tblWidth -= 30; // substracting offsets for aesthetic purpose
    tblHeight -= 300; // 270; // substracting offsets for aesthetic purpose

    if (this.props.sideMenu) {
      tblWidth -= 200;
    }
    if (this.props.visibility) {
      tblHeight -= 221;
    }

    if (tblHeight < 200) {
      tblHeight = 200;
    }

    const data = this.props.materials.tableData;

    return (
      <div className="manage-marker-table">
        <div className="action-buttons">
          <button
            className="save-material-marker"
            disabled={!markerStatusChanged}
            onClick={this.save3GBMarkerMaterial}
          >
            <i className="icon icon-floppy" />
            Save Selected
          </button>
        </div>
        <Table
          rowHeight={rowHeight}
          rowsCount={data.length}
          onColumnResizeEndCallback={this._onColumnResizeEndCallback}
          isColumnResizing={false}
          width={tblWidth}
          height={tblHeight}
          headerHeight={headerHeight}
          {...this.state}
        >
          {sortedColumns.map((d, i) => {
            let width = columnWidths[d.columnLabel] || 120;
            const fix = i < fixColumn;
            const colKey = d.traitID || d.columnLabel;

            if (colKey) {
              const newwid = colKey.length * 9;
              width = width < newwid ? newwid : width;
            }
            // console.log(width, colKey);

            return (
              <Column
                key={
                  (!!d.traitID && d.traitID.toString().toLowerCase()) ||
                  (!!d.columnLabel && d.columnLabel.toString().toLowerCase())
                }
                header={
                  <MaterialHeaderCell
                    {...this.state}
                    data={d || {}}
                    traitID={d.traitID}
                    label={d.columnLabel}
                    showFilter={this._filter}
                  />
                }
                columnKey={colKey && colKey.toString()}
                width={width}
                isResizable
                fixed={fix}
                minWidth={tblCellWidth}
                cell={
                  <MaterialCell
                    data={data}
                    traitID={d.traitID}
                    markerMaterialMap={this.props.materials.markerMaterialMap}
                    toggleMaterialMarker={this.toggleMaterialMarker}
                  />
                }
              />
            );
          })}
        </Table>
        <Page
          testID={this.props.testID}
          pageNumber={this.state.pageNumber}
          pageSize={this.props.pageSize}
          records={this.props.records}
          filter={this.props.filter}
          filterLength={this.props.filter.length}
          onPageClick={this.props.pageClick}
          isBlocking={this.props.dirty}
          isBlockingChange={this.props.resetDirtyMarked}
          pageClicked={this.onPageClick}
          _fixColumn={this._fixColumn}
          clearFilter={this.clearFilter}
          dirtyMessage={this.props.dirtyMessage}
        />
      </div>
    );
  }
}

// Container
const mapStateToProps = state => ({
  sideMenu: state.sidemenuReducer,
  materials: state.assignMarker.materials,
  testValue: state.assignMarker.materials.markerMaterialMap,
  testID: state.rootTestID.testID,
  testTypeID: state.assignMarker.testType.selected,
  records: state.assignMarker.materials.totalRecords,
  filter: state.assignMarker.materials.filters,
  dirty: state.assignMarker.materials.dirty,
  pageSize: state.assignMarker.total.pageSize
});
const mapDispatchToProps = dispatch => ({
  toggleMaterialMarker: markerMaterialList =>
    dispatch(toggleMaterialMarker(markerMaterialList)),
  saveMarkerMaterial: materialsMarkers => dispatch(save3GBMarkerMaterial(materialsMarkers)),
  pageClick: obj => {
    // console.log(1, obj);
    // dispatch({ ...obj, type: 'FETCH_MATERIALS' });
    dispatch({ ...obj, type: 'FETCH_THREEGB' });
  },
  resetDirtyMarked: () => dispatch({ type: 'RESET_MARKER_DIRTY' })
});
const ThreeGBMarkTable = connect(mapStateToProps, mapDispatchToProps)(ThreeGBMarkTableComponent);

ThreeGBMarkTableComponent.defaultProps = {
  fixColumn: 0,
  pageNumber: 1,
  tblCellWidth: 100,
  tblHeight: 300,
  tblWidth: 1000,
  dirtyMessage: '',
  filter: []
};

ThreeGBMarkTableComponent.propTypes = {
  sideMenu: PropTypes.bool.isRequired,
  visibility: PropTypes.bool.isRequired,

  testTypeID: PropTypes.number.isRequired,
  testID: PropTypes.number.isRequired,
  fixColumn: PropTypes.number,
  pageSize: PropTypes.number.isRequired,
  pageNumber: PropTypes.number,
  tblCellWidth: PropTypes.number,
  tblWidth: PropTypes.number,
  tblHeight: PropTypes.number,
  materials: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  toggleMaterialMarker: PropTypes.func.isRequired,
  saveMarkerMaterial: PropTypes.func.isRequired,

  dirty: PropTypes.bool.isRequired,
  dirtyMessage: PropTypes.string,
  resetDirtyMarked: PropTypes.func.isRequired,
  pageClick: PropTypes.func.isRequired,
  records: PropTypes.number.isRequired,
  filter: PropTypes.array // eslint-disable-line react/forbid-prop-types
};

export default ThreeGBMarkTable;
