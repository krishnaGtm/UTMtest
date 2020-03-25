import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Table, Column } from 'fixed-data-table-2';
import 'fixed-data-table-2/dist/fixed-data-table.css';

import Datacell from './DataCell';
import HeaderCell from './HeaderCell';
// import connect from "react-redux/es/connect/connect";

class TableOverview extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: props.tblWidth,
      tblHeight: props.tblHeight,
      headerHeight: 40,
      rowHeight: 36,
      // hardcoded for correct sequence
      columns: [
        'periodName',
        'slotName',
        'breedingStationCode',
        'cropName',
        'requestUser',
        'markers',
        'plates',
        'testProtocolName'
      ],
      // hard coded for people friendly labels
      columnsMapping: {
        periodName: 'Week',
        slotName: 'Reservation Ticket No',
        breedingStationCode: 'Breeding station',
        cropName: 'Crop',
        requestUser: 'Requester',
        markers: '#tests',
        plates: '#plates',
        testProtocolName: 'Method'
      },
      // hard coded for current data widths
      columnsWidth: {
        periodName: 240,
        slotName: 160,
        breedingStationCode: 120,
        cropName: 80,
        requestUser: 200,
        markers: 80,
        plates: 80,
        testProtocolName: 80
      }
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.tblWidth !== this.props.tblWidth) {
      this.setState({ tblWidth: nextProps.tblWidth });
    }
    if (nextProps.tblHeight !== this.props.tblHeight) {
      this.setState({ tblHeight: nextProps.tblHeight });
    }
  }

  // getFilteredPeriodsData = period => {
  //   console.log(this.props.data, period);
  //   const { data } = this.props;
  //   if (period !== '') {
  //     return data.filter(record => record.periodName === period);
  //   }
  //   return data;
  // };

  render() {
    const {
      headerHeight,
      rowHeight,
      columns,
      columnsMapping,
      columnsWidth
    } = this.state;
    let { tblWidth, tblHeight } = this.state;

    tblWidth -= 30; // 80
    if (this.props.sideMenu) {
      tblWidth -= 200;
    }
    tblHeight -= 140;
    const { data } = this.props;
    return (
      <Table
        rowHeight={rowHeight}
        headerHeight={headerHeight}
        rowsCount={data.length}
        width={tblWidth}
        height={tblHeight}
        {...this.props}
        data={data}
      >
        {columns.map(col => (
          <Column
            key={col}
            columnKey={col}
            header={<HeaderCell {...this.props} value={columnsMapping[col]} />}
            flexGrow={1}
            cell={({ ...props }) => {
              const { rowIndex, columnKey } = props;
              return <Datacell value={data[rowIndex][columnKey]} />;
            }}
            width={columnsWidth[col]}
          />
        ))}
      </Table>
    );
  }
}

const mapState = state => ({
  sideMenu: state.sidemenuReducer
});

TableOverview.defaultProps = {
  data: [],
  period: ''
};

TableOverview.propTypes = {
  data: PropTypes.array, // eslint-disable-line
  tblHeight: PropTypes.number.isRequired,
  tblWidth: PropTypes.number.isRequired,
  period: PropTypes.string
};
export default connect(mapState, null)(TableOverview);
