import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Table, Column } from 'fixed-data-table-2';

import HeaderCell from './components/HeaderCell';
import Datacell from './components/DataCell';
import RelationAction from './components/RelationAction';
import ResultAction from './components/ResultAction';
import BreederAction from './components/BreederAction';
import LaboverviewAction from './components/LaboverviewAction';
import MailAction from './components/MailAction';
import './phtable.scss';
import Page from '../Page/Page';

class PHTable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,
      data: props.data,
      // headerHeight: 40,
      rowHeight: 36,
      visibility: false,
      columns: props.columns,
      columnsMapping: props.columnsMapping,
      columnsWidth: props.columnsWidth,
      selection: props.selection || false,
      selectArray: props.selectArray | []
    };

    this._onColumnResizeEndCallback = this._onColumnResizeEndCallback.bind(
      this
    );
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.selectArray) {
      this.setState({ selectArray: nextProps.selectArray });
    }
    if (nextProps.tblWidth !== this.props.tblWidth) {
      this.setState({ tblWidth: nextProps.tblWidth });
    }
    if (nextProps.tblHeight !== this.props.tblHeight) {
      this.setState({ tblHeight: nextProps.tblHeight });
    }
    if (nextProps.data) {
      this.setState({
        data: nextProps.data
      });
    }
  }

  _onColumnResizeEndCallback(newColumnWidth, columnKey) {
    this.setState(({ columnsWidth }) => ({
      columnsWidth: {
        ...columnsWidth,
        [columnKey]: newColumnWidth
      }
    }));
  }

  /*selectRow = (rowIndex, shift, ctrl) => {
    const { selection, selectArray } = this.state;
    if (selection) {

      console.log('if selection true', rowIndex, shift, ctrl);
      if(ctrl) {
        console.log("ctrl");
        if (!selectArray.includes(rowIndex)) {
          this.setState({
            selectArray: [...selectArray, rowIndex]
          });
        }  else {
          const ind = selectArray.indexOf(rowIndex);
          const newSelect = [
            ...selectArray.slice(0, ind),
            ...selectArray.slice(ind + 1)
          ];
          if (newSelect.length === 0) {
            this.setState({ selectArray: [] });
          }
          this.setState({
            selectArray: newSelect
          });
        }
      } else if (shift) {
        console.log("shift");
        const newShiftArray = this.state.selectArray;
        newShiftArray.push(rowIndex);
        newShiftArray.sort((a, b) => a - b);
        const preArray = [];
        for (
          let i = newShiftArray[0];
          i <= newShiftArray[newShiftArray.length - 1];
          i += 1
        ) {
            preArray.push(i);
        }
        this.setState({selectArray: preArray });
      } else {
        console.log('Single click');
        const checkSelect = selectArray.includes(rowIndex);
        if (checkSelect) {
          this.setState({ selectArray: [] });
        } else {
          this.setState({ selectArray: [rowIndex] });
        }
      }

    }
  };*/

  handle = () => {
    // console.log(d);
    this.setState({
      visibility: !this.state.visibility
    });
  };

  pageClick = pg => this.props.pageChange(pg);

  render() {
    const {
      // headerHeight,
      rowHeight,
      columns,
      columnsMapping,
      columnsWidth,
      data,
      visibility,

      selectArray
    } = this.state;
    let { tblWidth, tblHeight } = this.state;

    let tblHeaderHeight = 90; // 90;
    if (!visibility) {
      tblHeaderHeight = 40;
    }

    // tblWidth = tblWidth > 1000 ? 900 : tblWidth;
    // tblHeight = tblHeight > 900 ? 600 : tblHeight;
    // console.log(tblHeight);
    // if (tblHeight !== 155) tblHeight -= 150;

    tblWidth -= 30;
    // tblHeight -= 20;
    if (this.props.sideMenu) {
      tblWidth -= 210;
    }
    // if (tblHeight < 400) {
    //   tblHeight = 640;
    // }
    const { pagesize, pagenumber, total } = this.props;
    const mod = total/pagesize;
    if (mod > 1) {
      // console.log(pagesize, pagenumber, total);
      // console.log('mod', total / pagesize);
      tblHeight -= 45;
    }
    if (this.props.fileSource) {
      // tblHeight -= 25;
    }

    // table height can't be less than 200
    tblHeight = tblHeight < 200 ? 200 : tblHeight;
    // console.log('columns', columns);

    return (
      <div className="phtable">
        <br />
        <Table
          rowHeight={rowHeight}
          headerHeight={tblHeaderHeight}
          rowsCount={data.length}
          onColumnResizeEndCallback={this._onColumnResizeEndCallback}
          onRowMouseDown={(event, rowIndex) => {
            let shiftK = false;
            let ctrlK = false;
            if (event.ctrlKey) {
              ctrlK = true;
            }
            if (event.shiftKey) {
              shiftK = true;
            }
            if (this.props.selectRow) {
              this.props.selectRow(rowIndex, shiftK, ctrlK);
            }
          }}
          isColumnResizing={false}
          width={tblWidth}
          height={tblHeight}
          {...this.props}
          data={data}
        >
          {columns.map(col => {
            // console.log(col, columnsMapping);
            let fixed = 0;
            // console.log(columnsMapping[col].fixed);
            if (columnsMapping && columnsMapping[col]) {
              // console.log(columnsMapping[col].fixed, ' -- ');
              fixed = columnsMapping[col].fixed ? 1 : 0;
            }

            let matchValue = '';
            {/*console.log(11, this.props.filter);*/}
            {/*console.log(typeof this.props.filter);*/}
            this.props.filter.map(f => {
              {/*console.log(f.name, col);*/}
              if ((f.name).toString().toLocaleLowerCase() === col.toString().toLocaleLowerCase()) {
                matchValue = f.value;
              }
              //cropCode
            });
            {/*console.log('matchValue', matchValue);*/}
            // console.log('fixed', fixed);
            return (
              <Column
                key={col}
                columnKey={col}
                header={
                  <HeaderCell
                    {...this.props}
                    value={columnsMapping[col]}
                    activeFilter={visibility}
                    onClick={() => { }}
                    handle={this.handle}
                    filterFetch={this.props.filterFetch}
                    filterValue={matchValue}
                  />
                }
                flexGrow={fixed}
                cell={({ ...props }) => {
                  const { rowIndex, columnKey } = props;
                  {/*console.log(props);*/}
                  if (columnKey === 'Action') {
                    if (this.props.actions.name === 'relation') {
                      // console.log(data);
                      return (
                        <RelationAction
                          data={data[rowIndex]}
                          onUpdate={this.props.actions.edit}
                          onRemove={this.props.actions.delete}
                        />
                      );
                    }
                    if (this.props.actions.name === 'result') {
                      return (
                        <ResultAction
                          data={data[rowIndex]}
                          ids={rowIndex}
                          onUpdate={this.props.actions.edit}
                          onRemove={this.props.actions.delete}
                        />
                      );
                    }
                    if (this.props.actions.name === 'laboverview') {
                      return <LaboverviewAction
                        data={data[rowIndex]}
                        ids={rowIndex}
                        onUpdate={this.props.actions.edit}
                        onRemove={() => { }}
                      />;
                    }
                    if (this.props.actions.name === 'breeder') {
                      return (
                        <BreederAction
                          data={data[rowIndex]}
                          ids={rowIndex}
                          onUpdate={this.props.actions.edit}
                          onRemove={this.props.actions.delete}
                        />
                      );
                    }
                    if (this.props.actions.name === 'mail') {
                      return (
                        <MailAction
                          data={data[rowIndex]}
                          ids={rowIndex}
                          onAdd={this.props.actions.add}
                          onUpdate={this.props.actions.edit}
                          onRemove={this.props.actions.delete}
                        />
                      );
                    }
                  }
                  return <Datacell value={data[rowIndex][columnKey]} {...props} selectArray={selectArray} />;
                }}
                width={columnsWidth[col]}
                isResizable
                minWidth={100}
              />
            );
          })}
        </Table>

        <Page
          testID={10}
          pageNumber={this.props.pagenumber}
          pageSize={this.props.pagesize}
          records={this.props.total}
          filter={[]}
          onPageClick={() => {}}
          isBlocking={false}
          isBlockingChange={() => {}}
          pageClicked={this.pageClick}
          resetSelect={() => {}}
          clearFilter={this.props.filterClear}
          filterLength={this.props.filter.length}
        />
      </div>
    );
  }
}

PHTable.defaultProps = {
  actions: {},
  fileSource: false
};

PHTable.propTypes = {
  fileSource: PropTypes.bool,
  filterFetch: PropTypes.func.isRequired,
  filterClear: PropTypes.func.isRequired,
  pageChange: PropTypes.func.isRequired,
  data: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  columns: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  actions: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  columnsMapping: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  columnsWidth: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  tblWidth: PropTypes.number.isRequired,
  tblHeight: PropTypes.number.isRequired,
  pagenumber: PropTypes.number.isRequired,
  pagesize: PropTypes.number.isRequired,
  total: PropTypes.number.isRequired,
  sideMenu: PropTypes.bool.isRequired
};

export default PHTable;
