/**
 * Created by psindurakar on 12/13/2017.
 */
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { Table, Column } from 'fixed-data-table-2';
import shortid from 'shortid';
import 'fixed-data-table-2/dist/fixed-data-table.css';
import '../../../../../../node_modules/fixed-data-table-2/dist/fixed-data-table.min';
import TableAction from './components/TableAction';
import CreateReplica from './components/CreateReplica';
import MoveForm from './components/Move';
import FillingHeaderCell from './FillingHeaderCell';
import ConfirmBox from '../../../../components/Confirmbox/confirmBox';
import MyCell from '../../../../helpers/MyCell';
import './table.scss';

class TableData extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      columnWidths: {},
      testID: props.testID,
      statusCode: props.statusCode,
      // fixColumn: props.fixColumn,
      headerHeight: 40,
      rowHeight: 36,
      pageNumber: props.pageNumber,
      pageSize: props.pageSize,
      tblCellWidth: props.tblCellWidth,
      tblWidth: props.tblWidth,
      tblHeight: props.tblHeight,
      selected: props.selected || null,
      selectArray: props.selectArray || [],
      dataList: props.dataList,
      isBlocking: props.isBlocking,
      moveShow: false,
      createReplicaModalVisibility: false,
      deletePlantConfirmBoxVisibility: false,
      importLevel: props.importLevel,
    };
    this._onColumnResizeEndCallback = this._onColumnResizeEndCallback.bind(
      this
    );
  }
  componentDidMount() {
    const { columnList } = this.props;
    const obj = this._columnSize(columnList);
    this.setState({ // eslint-disable-line
      columnWidths: { ...obj }
    });
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.importLevel !== this.props.importLevel) {
      this.setState({
        importLevel: nextProps.importLevel
      });
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
    if (nextProps.testID !== this.props.testID) {
      this.setState({
        testID: nextProps.testID
      });
    }
    if (nextProps.statusCode !== this.props.statusCode) {
      this.setState({
        statusCode: nextProps.statusCode
      });
    }
    if (nextProps.fixColumn !== this.props.fixColumn) {
      this.setState({
        fixColumn: nextProps.fixColumn
      });
    }

    if (nextProps.dataList) {
      this.setState({
        dataList: nextProps.dataList
      });
    }
    if (
      nextProps.selected ||
      nextProps.selected === null ||
      nextProps.selected === 0
    ) {
      this.setState({
        selected: nextProps.selected
      });
    }
    if (nextProps.selectArray) {
      this.setState({
        selectArray: nextProps.selectArray
      });
    }
    if (nextProps.isBlocking !== this.props.isBlocking) {
      this.setState({
        isBlocking: nextProps.isBlocking
      });
    }
    if (nextProps.columnList.length !== this.props.columnList.length) {
      const { columnList } = nextProps;
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
  }
  _columnSize = fields => {
    const obj = {};
    fields.map(d => {
      let width = 120;
      const newwid = d.columnLabel.length * 8 + 40;
      obj[d.columnLabel] = width < newwid ? newwid : width;;
      return null;
    });
    return obj;
  };
  _onColumnResizeEndCallback(newColumnWidth, columnKey) {
    this.setState(({ columnWidths }) => ({
      columnWidths: {
        ...columnWidths,
        [columnKey]: newColumnWidth
      }
    }));
  }
  _onRowClick = i => {
    alert(i); // eslint-disable-line
  };
  _filter = () => {
    this.setState({
      headerHeight: this.state.headerHeight === 40 ? 90 : 40
    });
  };
  selectRow = (rowIndex, shift, ctrl) => {
    const { selectArray } = this.state;
    const match = selectArray.includes(rowIndex);
    const index = rowIndex;
    // console.log(match);

    // if (!shift && !ctrl && match) {
    // }

    // SELECTING ROW TWICE REMOVES THE SELECTION
    /* if (rowIndex == this.state.selected) {
     index = null;
     } */
    // CHECKING IF THE ROW IS FIXED OR NOT
    this.props.selectedChange(index, shift, match, ctrl);
    // if (!this.state.dataList[rowIndex].fixed) {
    //   this.setState({selected: index })
    // }
  };
  findIndex = (array, element, delta) => {
    let t = element + delta;
    if (delta < 1) {
      if (t < 0) return -1;
      let check = true;
      do {
        if (array[t]) {
          check = array[t].fixed;
          if (check === false) break;
        }
        t -= 1;
      } while (t >= 0);
      // IF EVERY LOOP OBJECT HAVE FIXED VALUE TURE,
      // RETURNS -1
      if (check) return -1;
      this.selectRow(t);
      return t;
    } else { // eslint-disable-line
      const len = array.length - 1;
      let check = false;
      do {
        if (array[t]) {
          check = array[t].fixed;
          if (check === false) break;
        }
        t += 1;
      } while (t < len);
      if (check) return -1;
      this.selectRow(t);
      return t;
    }
  };
  up = () => {
    if (this.state.selected > 0) {
      const data = this.props.dataList;
      const { selected } = this.state;
      const resultIndex = this.findIndex(data, selected, -1);
      this.props.move(selected, resultIndex);
      this.props.selectArrayChange(resultIndex);
      this.props.isBlockingChange(true);
    }
  };
  down = () => {
    const position = this.state.selected + 1;
    if (this.state.dataList.length > position) {
      const data = this.props.dataList;
      const { selected } = this.state;
      const resultIndex = this.findIndex(data, selected, 1);
      this.props.move(selected, resultIndex);
      this.props.selectArrayChange(resultIndex);
      this.props.isBlockingChange(true);
    }
  };
  moveBtn = () => {
    this.setState({
      moveShow: true
    });
  };
  moveClose = () => {
    this.setState({
      moveShow: false
    });
  };
  handleDeletePlantBtnClick = () => {
    if (this.state.isBlocking) {
      this.props.show_error({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please save your changes before deleting a Plant.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
    } else {
      this.setState({
        deletePlantConfirmBoxVisibility: true
      });
    }
  };
  deletePlant = condition => {
    // console.log(this.state.dataList);
    if (condition) {
      const { selectArray, dataList, testID } = this.state;
      // selected
      // const { materialID } = dataList[selected];
      const deleteList = selectArray.map(d => dataList[d].wellID);
      // console.log(dataList[d]);
      // return dataList[d].materialID;
      // return null;

      // console.log(deleteList, testID);
      this.props.deleteCall(deleteList, testID);
      this.props.resetSelect();
      // this.props.selectArrayChange(null);
      // this.props.deleteCall(materialID, testID);
    }
    this.setState({
      deletePlantConfirmBoxVisibility: false
    });
  };

  undoDelete = () => {
    const { selectArray, dataList, testID } = this.state;
    // const { materialID } = dataList[selected];
    // const deleteList = selectArray.map(d => dataList[d].materialID);
    // const deleteList = selectArray.map(d => dataList[d].materialID);
    const deleteList = selectArray.map(d => dataList[d].wellID);
    this.props.undoDead(deleteList, testID);
    this.props.resetSelect();
  };

  replicaDelete = () => {
    const { selected, dataList, testID } = this.state;
    // const { breedingStationCode, cropCode } = this.props;
    const { materialID, wellID } = dataList[selected];

    this.props.deleteReplica(materialID, wellID, testID);
    this.props.resetSelect();
  };

  handleCreateReplicaBtnClick = () => {
    if (this.state.isBlocking) {
      this.props.show_error({
        type: 'NOTIFICATION_SHOW',
        status: true,
        message: ['Please save your changes before creating any replicas.'],
        messageType: 2,
        notificationType: 0,
        code: ''
      });
    } else {
      this.setState({
        createReplicaModalVisibility: true
      });
    }
  };
  closeCreateReplicaModal = () => {
    this.setState({
      createReplicaModalVisibility: false
    });
  };
  undoFixed = () => {
    const { testID, selected, dataList } = this.state;
    const { materialID, well: wellPosition } = dataList[selected];
    // console.log(testID, materialID, wellPosition);
    if (testID && materialID && wellPosition) {
      // console.log(dataList[selected]);
      this.props.undoFixedPosition({
        testID,
        materialID,
        wellPosition
      });
    }
  };

  tableActionUI = () => {
    const btnStat = this.state.statusCode >= 400;
    const { importLevel, selected, selectArray, dataList } = this.state;
    const calSelected = selected !== null && selected > 0;
    // console.log(selected, selectArray, calSelected, btnStat);
    if (btnStat) return null;
    if (dataList[selected] === undefined) return null;
    if (calSelected || selectArray.length > 0) {
      return (
        <TableAction
          importLevel={importLevel}
          up={this.up}
          down={this.down}
          move={this.moveBtn}
          del={this.handleDeletePlantBtnClick}
          btnStat={!btnStat}
          selected={selected}
          selectArray={selectArray.length > 1}
          selectArrayLength={selectArray.length || 0}
          handleCreateReplicaBtnClick={this.handleCreateReplicaBtnClick}
          undo={this.undoDelete}
          replicaDelete={this.replicaDelete}
          data={dataList}
          undoFixed={this.undoFixed}
        />
      );
    }
    return null;
  };

  render() {
    if (this.props.columnLength < 1) {
      return null;
    }
    // for order button show and hide in status condition
    let { tblWidth, tblHeight } = this.state;
    const {
      // tblCellWidth,
      // fixColumn,
      columnWidths,
      headerHeight,
      rowHeight,
      selected,
      selectArray
    } = this.state;
    // dataList,

    tblWidth -= 30;
    if (this.props.sideMenu) {
      tblWidth -= 200;
    }
    tblHeight -= 240;
    tblHeight = tblHeight < 200 ? 200 : tblHeight;
    let columns = this.props.columnList;
    const len = 3;
    let count = 0;
    const part = [];
    const part1 = [];
    const part2 = [];
    const part3 = [];
    columns.map(col => {
      switch (col.columnType) {
        case 1:
          part1.push(col);
          break;
        case 2:
          if (count < len) {
            part.push(col);
            count += 1;
          } else {
            part2.push(col);
          }
          break;
        case 3:
          part3.push(col);
          break;
        default:
          break;
      }
      return null;
    });
    columns = part.concat(part3, part1, part2);
    // console.log(part3, part1, part2);
    const data = this.state.dataList;

    return (
      <div style={{ position: 'relative' }}>
        {this.state.deletePlantConfirmBoxVisibility && (
          <ConfirmBox
            click={this.deletePlant}
            message="Are you sure you want to delete selected record(s)?"
          />
        )}

        {this.tableActionUI()}

        <MoveForm
          moveShow={this.state.moveShow}
          ids={selectArray}
          close={this.moveClose}
          selected={this.props.selectedChange}
          selectedArray={this.props.selectArrayChange}
          blockChange={this.props.isBlockingChange}
        />
        <CreateReplica
          visibility={this.state.createReplicaModalVisibility}
          closeModal={this.closeCreateReplicaModal}
          selectedIndexes={selectArray}
          testID={this.state.testID}
          resetSelectedArray={this.props.selectedChange}
          data={this.state.dataList}
        />
        <Table
          rowHeight={rowHeight}
          rowsCount={data.length}
          onRowMouseDown={(event, rowIndex) => {
            let shiftK = false;
            let ctrlK = false;
            if (event.ctrlKey) {
              ctrlK = true;
            }
            if (event.shiftKey) {
              shiftK = true;
            }
            this.selectRow(rowIndex, shiftK, ctrlK);
          }}
          {...this.props}
          scrollToRow={selected}
          onColumnResizeEndCallback={this._onColumnResizeEndCallback}
          isColumnResizing={false}
          width={tblWidth}
          height={tblHeight}
          headerHeight={headerHeight}
          {...this.state}
        >
          {columns.map(d => {
            // console.log(d);
            const width = columnWidths[d.columnLabel] || 80;
            const { traitID } = d;
            const fix = d.fixed === 1; // i < fixColumn;
            const colKey = d.traitID || d.columnLabel;
            const { columnType } = d;
            return (
              <Column
                key={shortid.generate()}
                header={
                  <FillingHeaderCell
                    {...this.state}
                    data={d}
                    testID={this.props.testID}
                    traitID={traitID}
                    label={d.columnLabel}
                    fetchData={this.props.fetchData}
                    showFilter={this._filter}
                  />
                }
                columnKey={colKey}
                width={width}
                isResizable={true} // eslint-disable-line
                fixed={fix}
                // minWidth={tblCellWidth}
                flexGrow={1}
                cell={
                  <MyCell
                    data={data}
                    selected={selected}
                    selectArray={selectArray}
                    columnType={columnType}
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
  columnList: state.plateFilling.column,
  dataList: state.plateFilling.data,
  statusCode: state.rootTestID.statusCode,
});
const mapDispatchToProps = dispatch => ({
  move: (frm, to) => {
    dispatch({
      type: 'DATA_ROW_MOVE',
      frm,
      to
    });
  },
  deleteCall: (wellIDs, testID) => {
    dispatch({
      type: 'REQUEST_DATA_DELETE',
      testID,
      wellIDs
    });
  },
  undoDead: (wellIDs, testID) => {
    dispatch({
      type: 'REQUEST_UNDO_DELETE',
      wellIDs,
      testID
    });
  },
  deleteReplica: (materialID, wellID, testID) => {
    dispatch({
      type: 'REQUEST_DELETE_REPLICATE',
      materialID,
      wellID,
      testID
    });
  },
  undoFixedPosition: obj => {
    // console.log(obj);
    dispatch({
      type: 'REQUEST_UNDO_FIXEDPOSITION',
      ...obj
    });
  },
  show_error: obj => {
    dispatch(obj);
  }
});

TableData.defaultProps = {
  cropCode: null,
  fileDataLength: null,
  fileID: null,
  well: null,
  fetchData: null,
  remarkRequired: null,
  statusCode: null,
  testTypeID: null,
  testID: null,
  selected: null,
  fixColumn: 0,
};
TableData.propTypes = {
  sideMenu: PropTypes.bool.isRequired,
  columnLength: PropTypes.number.isRequired,
  columnList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  confirmDial: PropTypes.bool.isRequired,
  cropCode: PropTypes.string,
  dataList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  deleteCall: PropTypes.func.isRequired,
  resetSelect: PropTypes.func.isRequired,
  undoDead: PropTypes.func.isRequired,
  deleteReplica: PropTypes.func.isRequired,
  fetchData: PropTypes.func,
  fileDataLength: PropTypes.number,
  fileID: PropTypes.number,
  fixColumn: PropTypes.number,
  goToAssignMarker: PropTypes.bool.isRequired,
  isBlocking: PropTypes.bool.isRequired,
  isBlockingChange: PropTypes.func.isRequired,
  move: PropTypes.func.isRequired,
  pageClick: PropTypes.func.isRequired,
  pageNumber: PropTypes.number.isRequired,
  pageSize: PropTypes.number.isRequired,
  plantID: PropTypes.oneOfType([PropTypes.number, PropTypes.string]).isRequired,
  plantList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  plantSuggestions: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  plantValue: PropTypes.string.isRequired,
  remarkRequired: PropTypes.bool,
  selectArray: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  selectArrayChange: PropTypes.func.isRequired,
  selected: PropTypes.number,
  selectedChange: PropTypes.func.isRequired,
  show_error: PropTypes.func.isRequired,
  undoFixedPosition: PropTypes.func.isRequired,
  statusCode: PropTypes.number,
  statusList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  suggestions: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  tblCellWidth: PropTypes.number.isRequired,
  tblHeight: PropTypes.number.isRequired,
  tblWidth: PropTypes.number.isRequired,
  testID: PropTypes.number,
  testTypeID: PropTypes.number,
  testTypeName: PropTypes.string.isRequired,
  well: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  wellTypeID: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  wellValue: PropTypes.string.isRequired,
  importLevel: PropTypes.bool.isRequired,
};

export default connect(mapStateToProps, mapDispatchToProps)(TableData);
