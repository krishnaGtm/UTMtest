import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { Table, Column } from 'fixed-data-table-2';
// import lodash from 'lodash';
// import shallowCompare from 'react-addons-shallow-compare';
import 'fixed-data-table-2/dist/fixed-data-table.css';
import HeaderCell from '../../../helpers/HeaderCell';
import MyCell from '../../../helpers/MyCell';

class TableDataComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      columnWidths: {},
      fixColumn: props.fixColumn,
      headerHeight: 40,
      rowHeight: 36,
      pageNumber: props.pageNumber,
      pageSize: props.pageSize,
      tblCellWidth: props.tblCellWidth,
      tblWidth: props.tblWidth,
      tblHeight: props.tblHeight,
      markerLength: props.markerLength
    };
    this._onColumnResizeEndCallback = this._onColumnResizeEndCallback.bind(
      this
    );
    this._filter = this._filter.bind(this);
    this._columnSize = this._columnSize.bind(this);
  }

  componentWillMount() {
    // console.log('comp mount tableData')
    const { columnList } = this.props;
    const obj = this._columnSize(columnList);

    this.setState({
      columnWidths: { ...obj }
    });
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.fixColumn !== this.props.fixColumn) {
      this.setState({
        fixColumn: nextProps.fixColumn
      });
    }

    // const test = shallowCompare(nextProps.columnList, this.props.columnList);
    // console.log(test);

    // if (nextProps.columnList.length > 0) {
    if (nextProps.columnList.length !== this.props.columnList.length) {
      const { columnList } = this.props;
      const obj = this._columnSize(columnList);
      this.setState({
        columnWidths: { ...obj }
      });
    }
    if (nextProps.pageNumber !== this.props.pageNumber) {
      this.setState({
        pageNumber: nextProps.pageNumber
      });
    }
    if (nextProps.pageSize !== this.props.pageSize) {
      this.setState({
        pageSize: nextProps.pageSize
      });
    }
    if (nextProps.tblWidth) {
      this.setState({
        tblWidth: nextProps.tblWidth
      });
    }
    if (nextProps.tblHeight) {
      this.setState({
        tblHeight: nextProps.tblHeight
      });
    }
    if (nextProps.markerLength !== this.props.markerLength) {
      this.setState({
        markerLength: nextProps.markerLength
      });
    }
  }

  _columnSize(fields) { // eslint-disable-line
    const obj = {};
    fields.map(d => {
      const { columnLabel } = d;
      const nW = columnLabel.length * 8 + 20;
      // console.log(nW, columnLabel.length);
      // if (d.columnLabel === 'Stb.shrt') {
      //   obj[d.columnLabel] = 220;
      // } else if (d.columnLabel === 'Status') {
      //   obj[d.columnLabel] = 200;
      // } else {
      obj[d.columnLabel] = nW < 120 ? 140 : nW;
      // }
      return null;
    });
    return obj;
  }

  _onColumnResizeEndCallback(newColumnWidth, columnKey) {
    this.setState(({ columnWidths }) => ({
      columnWidths: {
        ...columnWidths,
        [columnKey]: newColumnWidth
      }
    }));
  }

  // JUST SHOW AND HIDE FILTER SECTION
  _filter() {
    const hh = this.state.headerHeight;
    this.setState({
      headerHeight: hh === 40 ? 90 : 40
    });
  }

  render() {
    // console.log('tableData.js', this.props.dataList);
    const {
      tblCellWidth,
      fixColumn,
      columnWidths,
      headerHeight,
      rowHeight
    } = this.state;
    let { tblWidth, tblHeight, markerLength } = this.state;
    // console.log('am', tblWidth, tblHeight);
    tblWidth -= 15;

    const  { sideMenu, columnList: columns, dataList: data, markerShow, visibility, testTypeID } = this.props;
    // console.log('mm', markerLength, markerShow, ' = ', this.props.show);

    if (sideMenu) { tblWidth -= 220; }

    if (markerLength === 0) {
      tblHeight -= 160;
    } else {
      tblHeight -= 320;
    }

    if (!markerShow) {
      tblHeight += 75;
    } else {
      tblHeight -= 40; // 40
    }
    // if SelectFileAttribute in visible
    if (visibility) { tblHeight -= 220; }
    // console.log('v', this.props.visibility, 's', this.props.show, ' - ', tblHeight);
    if (testTypeID === 2 || testTypeID === 4 || testTypeID === 5) {
      tblHeight -= 60;
    }
    tblHeight -= 40;

    if (tblHeight < 200) { tblHeight = 200; }

    return (
      <div>
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
          {columns.map((d, i) => {
            // console.log(d.fixed, d.fixed === 1);
            const minWidth = 120;
            const compWidth = columnWidths[d.columnLabel] || d.columnLabel.length * 10 || minWidth;
            const width = compWidth < minWidth ? minWidth : compWidth;
            // console.log(width, d.columnLabel, columnWidths[d.columnLabel]);
            const { traitID } = d;
            // const fix = i < fixColumn;
            const fix = d.fixed === 1; //
            const colKey = d.traitID || d.columnLabel;
            return (
              <Column
                key={i} // eslint-disable-line
                header={
                  <HeaderCell
                    {...this.state}
                    data={d}
                    traitID={traitID}
                    label={d.columnLabel}
                    showFilter={this._filter}
                  />
                }
                columnKey={colKey}
                width={width}
                isResizable
                fixed={fix}
                minWidth={tblCellWidth}
                cell={
                  <MyCell
                    data={data}
                    traitID={d.traitID}
                    click={this._onRowClick}
                  />
                }
              />
            );
          })}
        </Table>
      </div>
    );
  }
}

const mapStateToProps = state => ({
  sideMenu: state.sidemenuReducer,
  markerLength: state.assignMarker.marker.length,
  columnList: state.assignMarker.column,
  dataList: state.assignMarker.data
});

TableDataComponent.defaultProps = {
  markerLength: 0,
  selected: null,
  plantList: [],
  plantSuggestions: [],
  selectArray: [],
  suggestions: [],
  well: [],
  wellTypeID: [],
  deleteCall: null,
  isBlockingChange: null,
  pageClick: null,
  selectArrayChange: null,
  selectedChange: null,
  show_error: null,
  move: null,
  confirmDial: null,
  goToAssignMarker: null,
  isBlocking: null,
  plantID: null,
  plantValue: null,
  remarkRequired: null,
  testTypeName: null,
  wellValue: null
};
TableDataComponent.propTypes = {
  markerLength: PropTypes.number.isRequired,
  // fixColumn: PropTypes.number.isRequired,
  pageNumber: PropTypes.number.isRequired,
  columnLength: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  selected: PropTypes.number,
  statusCode: PropTypes.number.isRequired,
  tblHeight: PropTypes.number.isRequired,
  tblWidth: PropTypes.number.isRequired,
  tblCellWidth: PropTypes.number.isRequired,
  testID: PropTypes.number.isRequired,
  testTypeID: PropTypes.number.isRequired,
  columnList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  dataList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  plantList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  plantSuggestions: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  selectArray: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  statusList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  suggestions: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  well: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  wellTypeID: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  deleteCall: PropTypes.func,
  isBlockingChange: PropTypes.func,
  pageClick: PropTypes.func,
  selectArrayChange: PropTypes.func,
  selectedChange: PropTypes.func,
  show_error: PropTypes.func,
  move: PropTypes.func,
  confirmDial: PropTypes.bool,
  goToAssignMarker: PropTypes.bool,
  isBlocking: PropTypes.bool,
  markerstatus: PropTypes.bool.isRequired,
  plantID: PropTypes.string,
  plantValue: PropTypes.string,
  remarkRequired: PropTypes.string,
  testTypeName: PropTypes.string,
  wellValue: PropTypes.string
};

const TableData = connect(mapStateToProps)(TableDataComponent);
export default TableData;
