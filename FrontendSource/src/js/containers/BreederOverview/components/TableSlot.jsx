import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { Table, Column } from 'fixed-data-table-2';
import 'fixed-data-table-2/dist/fixed-data-table.css';

import Datacell from './DataCell';
import HeaderCell from './HeaderCell';

import Page from '../../../components/Page/Page';

class TableSlot extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: props.tblWidth,
      tblHeight: props.tblHeight,
      data: props.data,
      headerHeight: 40,
      rowHeight: 36,
      columns: [
        'cropCode',
        'breedingStationCode',
        'slotName',
        'periodName',
        'materialStateCode',
        'materialTypeCode',
        'statusName'
      ],
      columnsMapping: props.columnsMapping,
      columnsWidth: props.columnsWidth,
      visibility: false
    };

    this._onColumnResizeEndCallback = this._onColumnResizeEndCallback.bind(this);
  }

  componentWillReceiveProps(nextProps) {
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
    this.setState(({columnsWidth}) => ({
      columnsWidth: {
        ...columnsWidth,
        [columnKey]: newColumnWidth,
      }
    }));
  }

  handle = d => {
    // console.log(d);
    this.setState({
      visibility: !this.state.visibility
    });
  };

  pageClick = pg => {
    this.props.pageChange(pg);
  };

  render() {
    const {
      headerHeight,
      rowHeight,
      columns,
      columnsMapping,
      columnsWidth,
      data,
      visibility
    } = this.state;
    let { tblWidth, tblHeight } = this.state;

    // console.log(tblWidth, tblHeight, ' ----- ');

    let tblHeaderHeight = 90; // 90;
    if (!visibility) {
      tblHeaderHeight = 40;
    }

    // tblWidth = tblWidth > 1000 ? 900 : tblWidth;
    // tblHeight = tblHeight > 900 ? 600 : tblHeight;
    tblHeight -= 150;
    tblWidth -= 30;
    if (this.props.sideMenu) {
      tblWidth -= 200;
    }
    if (tblHeight < 400) {
      tblHeight = 640;
    }

    return (
      <div>

        <Table
          rowHeight={rowHeight}
          headerHeight={tblHeaderHeight}
          rowsCount={data.length}
          onColumnResizeEndCallback={this._onColumnResizeEndCallback}
          isColumnResizing={false}
          width={tblWidth}
          height={tblHeight}
          {...this.props}
          data={data}
        >
          {columns.map(col => (
            <Column
              key={col}
              columnKey={col}
              header={
                <HeaderCell
                  {...this.props}
                  value={columnsMapping[col]}
                  activeFilter={visibility}
                  onClick={() => {}}
                  handle={this.handle}
                  filterFetch={this.props.filterFetch}
                />
              }
              flexGrow={1}
              cell={({ ...props }) => {
                const { rowIndex, columnKey } = props;
                return <Datacell value={data[rowIndex][columnKey]} />;
              }}
              width={columnsWidth[col]}
              isResizable
              minWidth={100}
            />
          ))}
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
          resetSelect={() => {}} // eslint-disable-line
          clearFilter={this.props.filterClear}
          filterLength={this.props.filter.length}
        />
      </div>
    );
  }
}

const mapState = state => ({
  sideMenu: state.sidemenuReducer,
  filter: state.slotBreeder.filter
});

export default connect(mapState, null)(TableSlot);