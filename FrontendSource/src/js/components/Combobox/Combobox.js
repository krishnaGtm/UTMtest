import React from 'react';
import PropTypes from 'prop-types';

const DropDown = ({ label, options, change, disabled, value = null, name = '', listName='', listCode='' }) => {
  let selected = '';
  let drawOption = '';
  if (listName !='' && listCode != '') {
    drawOption = options.map(d => (
       <option value={d[listCode]} key={d[listCode]}>
         {d[listName]}
       </option>
     ));
  } else {
    switch (label) {
      case 'Material Type':
        drawOption = options.map(d => {
          if (d.selected) {
            selected = d.materialTypeID;
          }
          return (
            <option key={d.materialTypeID} value={d.materialTypeID}>
              {d.materialTypeCode} - {d.materialTypeDescription}
            </option>
          );
        });
        break;
      case 'Material State':
        drawOption = options.map(d => {
          if (d.selected) {
            selected = d.materialStateID;
          }
          return (
            <option key={d.materialStateID} value={d.materialStateID}>
              {d.materialStateCode} - {d.materialStateDescription}
            </option>
          );
        });
        break;
      case 'Container Type':
        drawOption = options.map(d => {
          if (d.selected) {
            selected = d.containerTypeID;
          }
          return (
            <option key={d.containerTypeID} value={d.containerTypeID}>
              {d.containerTypeCode} - {d.containerTypeName}
            </option>
          );
        });
        break;
      case 'Test type':
        drawOption = options.map(d => (
          <option value={d.testTypeID} key={d.testTypeID}>
            {d.testTypeName}
          </option>
        ));
        break;
      case 'Slot':
        drawOption = options.map(d => (
          <option value={d.slotID} key={d.slotID}>
            {d.slotName}
          </option>
        ));
        break;
      case 'Project List':
        drawOption = [
          <option vaalue='1' key='1'>test 1</option>
        ];
        // options.map(d => (
        //   <option value={d.slotID} key={d.slotID}>
        //     {d.slotName}
        //   </option>
        // ));
        break;
      default:
        // console.log('Drops combo no label match');
    }
  }

  return (
    <div>
      <label>{label}</label> {/*eslint-disable-line*/}
      <select
        name={name}
        disabled={disabled}
        onChange={change}
        value={value === null ? selected : value}
      >
        <option>Select</option>
        {drawOption}
      </select>
    </div>
  );
};
DropDown.defaultProps = {
  value: null,
  disabled: false
};
DropDown.propTypes = {
  label: PropTypes.string.isRequired,
  change: PropTypes.func.isRequired,
  options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  value: PropTypes.number,
  disabled: PropTypes.bool
};
export default DropDown;
