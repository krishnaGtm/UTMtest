import React, { Component } from 'react';
import autoBind from 'auto-bind';
import { Cell } from 'fixed-data-table-2';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

class MaterialCellComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      statusCode: props.statusCode,
      valueNumber: 0 //this.computevalue() // props.columnKey === 'NrOfSamples' ? 200 : 0
    };
    this.min = 0;
    this.max = 92 * 5;

    autoBind(this);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.statusCode !== this.props.statusCode) {
      this.setState({
        statusCode: nextProps.statusCode
      });
    }
  }
  //
  toggleMaterialMarker(e) {
    const { traitID, rowIndex, data } = this.props;
    const key = `${data[rowIndex].materialID}-${traitID.toLowerCase()}`;
    const value = e.target.checked ? 1 : 0;
    this.props.toggleMaterialMarker([{ key, value }]);
  }
  toggleMaterialMarker3GB(e) {
    const { rowIndex, data } = this.props;
    // const key = `${data[rowIndex].materialKey}-d_Selected`;
    const key = `${data[rowIndex].materialKey}-d_To3GB`;
    const value = e.target.checked ? 1 : 0;
    // console.log(key, value, rowIndex);
    this.props.toggleMaterialMarker([{ key, value }]);
  }




  render() {
    const { traitID, rowIndex, data, columnKey, markerMaterialMap } = this.props;
    let cellData = '';
    const statusDisabled = this.props.statusCode >= 400;

    if (columnKey) {
      // if (columnKey.toLocaleLowerCase() === 'selected') {
      if (columnKey.toLocaleLowerCase() === 'to3gb') {

        const check3gb = `${data[rowIndex].materialKey}-d_To3GB`;
        // const check3gb = `${data[rowIndex].materialKey}-d_Selected`;
        // console.log('check3gb', check3gb);
        // const checkedStatus = 0; // data[rowIndex]['d_To3GB'] || 0;
        console.log(markerMaterialMap[check3gb])
        const checkedStatus = !!(markerMaterialMap[check3gb].newState || 0);
        // console.log('checkedStatus', checkedStatus);
        // const checkedStatus = markerMaterialMap[`${materialKey}-d_To3GB`].newState || 0;;
        return (
          <div className="tableCheck">
            <input
              id={`${check3gb}`}
              type="checkbox"
              disabled={statusDisabled}
              checked={checkedStatus}
              onChange={this.toggleMaterialMarker3GB}
            />
            <label htmlFor={`${check3gb}`} /> {/* eslint-disable-line  */}
          </div>
        );
      }
    }
    // console.log(data[rowIndex]);
    // SAMPLE NUMBER SECTION



    if (traitID) {
      // check if determination trait
      // if true paint checkbox
      // console.log(traitID);
      if (traitID.toString().substring(0, 2) === 'D_') {
        const { materialID } = data[rowIndex];
        const checkedStatus =
          markerMaterialMap[`${materialID}-${traitID.toLowerCase()}`].newState || 0;

        cellData = (
          <div className="tableCheck">
            <input
              id={`${materialID}-${traitID.toLowerCase()}`}
              type="checkbox"
              disabled={statusDisabled}
              checked={checkedStatus}
              onChange={this.toggleMaterialMarker}
            />
            <label htmlFor={`${materialID}-${traitID.toLowerCase()}`} /> {/* eslint-disable-line */}
          </div>
        );
      } else cellData = data[rowIndex][traitID];
    } else {
      // console.log(2);

      const row = data[rowIndex];
      const key =
        !!columnKey &&
        Object.keys(row).find(column => column.toLowerCase() === columnKey.toLowerCase());
      if (key) {
        cellData = row[key];
      }
    }
    return <Cell>{cellData}</Cell>;
  }
}

MaterialCellComponent.defaultProps = {
  traitID: null,
  columnKey: null
};

MaterialCellComponent.propTypes = {
  statusCode: PropTypes.number.isRequired,
  rowIndex: PropTypes.number.isRequired,
  columnKey: PropTypes.string,
  traitID: PropTypes.string,
  toggleMaterialMarker: PropTypes.func.isRequired,
  data: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  markerMaterialMap: PropTypes.object.isRequired // eslint-disable-line react/forbid-prop-types
};

const mapStateToProps = state => ({
  statusCode: state.rootTestID.statusCode
});

// const mapDispatchProps = dispatch => ({
//   sampleChange: (materialID, nrOfSample) => {
//     // console.log('sampleChange', materialID, nrOfSample);
//     dispatch({
//       type: 'SAMPLE_NUMBER_CHANGE',
//       materialID,
//       nrOfSample
//     });
//   }
// })
const MaterialCell = connect(mapStateToProps, null)(MaterialCellComponent);

export default MaterialCell;
