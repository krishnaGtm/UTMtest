// /**
//  * Created by psindurakar on 11/28/2017.
//  */
// import React from 'react';
// import { Table, Column, Cell } from 'fixed-data-table-2';
// import TextCell from '../../../helpers/cells';
// import '../../../../../node_modules/fixed-data-table-2/dist/fixed-data-table.min';
//
// class TableAssign extends React.Component {
//   longClickTimer = null;
//   displayColumns = {
//     firstName: 'First Name',
//     lastName: 'Last Name',
//     city: 'City',
//     street: 'zipCode'
//   };
//   constructor(props) {
//     super(props);
//     var dataList = [
//       {firstName :'rojesh', lastName:'nepal', city:'ktm', street:'123'},
//       {firstName :'james', lastName:'nepal', city:'pok', street:'321'}
//     ];
//     this.state = {
//       dataList,
//       columns: this.getColumns(),
//       longPressedRowIndex: -1,
//     };
//   }
//   handleRowMouseDown(rowIndex) {
//     this.cancelLongClick();
//     console.log('getIndex', rowIndex);
//     this.setState({
//       longPressedRowIndex: rowIndex
//     });
//     this.longClickTimer = setTimeout(() => {
//       this.setState({
//         longPressedRowIndex: rowIndex
//       });
//     }, 1000);
//   }
//
//   handleRowMouseUp() {
//     this.cancelLongClick();
//   }
//
//   cancelLongClick() {
//     if (this.longClickTimer) {
//       clearTimeout(this.longClickTimer);
//       this.longClickTimer = null;
//     }
//   }
//
//   getColumns() {
//     let columns = [];
//
//     Object.keys(this.displayColumns).forEach(columnKey => {
//       console.log(this.displayColumns, columnKey);
//       columns.push(
//         <Column
//           key={columnKey}
//           columnKey={columnKey}
//           flexGrow={2}
//           header={<Cell>{this.displayColumns[columnKey]}</Cell>}
//           cell={cell => this.getCell(cell.rowIndex, cell.columnKey)}
//           width={100}
//         />);
//     });
//
//     return columns;
//   }
//
//   getCell(rowIndex, columnKey) {
//     let isCellHighlighted = this.state.longPressedRowIndex === rowIndex;
//
//     let rowStyle = {
//       backgroundColor: isCellHighlighted ? 'yellow' : 'transparent',
//       width: '100%',
//       height: '100%'
//     }
//
//     return <TextCell style={rowStyle}
//                      data={this.state.dataList}
//                      rowIndex={rowIndex}
//                      columnKey={columnKey} />;
//   }
//
//   render() {
//     let tblWidth = this.props.tblWidth - 74;
//     return (
//       <Table
//         rowHeight={50}
//         headerHeight={50}
//         rowsCount={this.state.dataList.length}
//         width={tblWidth}
//         height={500}
//         onRowMouseDown={(event, rowIndex) => { this.handleRowMouseDown(rowIndex); }}
//         onRowMouseUp={(event, rowIndex) => { this.handleRowMouseUp(rowIndex); }}
//         {...this.props}>
//         {this.state.columns}
//       </Table>
//     );
//   }
// }
//
// const TableAssign1 = (props) => {
//   return <Table
//     rowHeight={50}
//     headerHeight={50}
//     rowsCount={3}
//     width={props.tblWidth}
//     height={400}
//     {...this.props}>
//     <Column
//       columnKey="avatar"
//       header={<Cell>Plant Name</Cell>}
//       cell={<Cell>Head1</Cell>}
//       width={250}
//     />
//     <Column
//       columnKey="Col1"
//       header={<Cell>Col1</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//     <Column
//       columnKey="Col2"
//       header={<Cell>Col2</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//     <Column
//       columnKey="col3"
//       header={<Cell>col3</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//     <Column
//       columnKey="col4"
//       header={<Cell>col4</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//     <Column
//       columnKey="col5"
//       header={<Cell>col5</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//     <Column
//       columnKey="col7"
//       header={<Cell>col7</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//     <Column
//       columnKey="col6"
//       header={<Cell>co65</Cell>}
//       cell={<Cell>
//         <input type="checkbox" />
//       </Cell>}
//       width={80}
//     />
//
//   </Table>
// }
// export default TableAssign
