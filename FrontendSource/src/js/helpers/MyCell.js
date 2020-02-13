import React from 'react';
import { Cell } from 'fixed-data-table-2';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

class MyCell extends React.Component {
  toCamelCase(aValue) {
    const value = aValue || '';
    if (value === '' || !isNaN(value) || !this.isUpper(value.charAt(0))) { // eslint-disable-line
      return value;
    }
    const chars = value.split('');
    for (let i = 0; i < chars.length; i += 1) {
      if (i === 1 && !this.isUpper(chars[i])) {
        break;
      }
      const hasNext = i + 1 < chars.length;
      if (i > 0 && hasNext && !this.isUpper(chars[i + 1])) {
        if (this.isSeparator(chars[i + 1])) {
          chars[i] = chars[i].toLowerCase();
        }
        break;
      }
      chars[i] = chars[i].toLowerCase();
    }
    return chars.join('');
  }
  isUpper = chr =>
    /[A-Z]|[\u0080-\u024F]/.test(chr) && chr === chr.toUpperCase();
  isSeparator = value => value === '';
  render() {
    const { rowIndex, traitID, columnType, selectArray, data } = this.props;
    let { columnKey } = this.props;
    const fixedRowBe = data[rowIndex].fixed;
    let cellValue = '';
    if (data.length) {
      columnKey = this.toCamelCase(columnKey);

      if (traitID) {
        cellValue = data[rowIndex][traitID];
      }
      if (traitID === null) {
        cellValue = data[rowIndex][columnKey];
      }
      if (columnType === 1) {
        const checked = data[rowIndex][columnKey] || 0;
        cellValue = (
          <div className="tableCheck">
            <input
              name={`box_${rowIndex}${columnKey}`}
              id={`box_${rowIndex}${columnKey}`}
              type="checkbox"
              onChange={() => {}}
              checked={checked}
              disabled="disabled"
            />
              <label htmlFor={`box_${rowIndex}${columnKey}`} /> {/*eslint-disable-line*/}
          </div>
        );
      }
    }
    let isCellHighlighted = false;
    if (selectArray) isCellHighlighted = selectArray.includes(rowIndex);

    // console.log(selectArray, rowIndex);
    // console.log(isCellHighlighted, fixedRowBe);

    const newStyle = {};
    this.props.getWellTypeID.map(d => {
      if (d.wellTypeID === data[rowIndex].wellTypeID) {
        if (d.bgColor !== '#fff' || d.fgColor !== '#000') {
          newStyle.background = isCellHighlighted ? '#8bce3f' : d.bgColor;
          newStyle.color = isCellHighlighted ? '#000' : d.fgColor;
        }
      }
      return null;
    });
    if (fixedRowBe) {
      return <Cell style={newStyle}>{cellValue}</Cell>;
    }
    if (isCellHighlighted) {
      newStyle.background = '#a2e456';
    }
    return <Cell style={newStyle}>{cellValue}</Cell>;
  }
}
const mapStateToProps = state => ({
  getWellTypeID: state.getWellTypeID
});
MyCell.defaultProps = {
  traitID: null,
  selectArray: null,
  columnType: null
};
MyCell.propTypes = {
  columnKey: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
    .isRequired,
  data: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  getWellTypeID: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  selectArray: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  rowIndex: PropTypes.number.isRequired,
  traitID: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  columnType: PropTypes.number
};
export default connect(mapStateToProps)(MyCell);
