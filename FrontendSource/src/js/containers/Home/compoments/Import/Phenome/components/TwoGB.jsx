import React, { Fragment } from 'react';

import DateInput from '../../../../../../components/DateInput';

class TwoGB extends React.Component {

  render() {
    const { importLevel } = this.props;

    return (
      <Fragment>
          <DateInput label="Planned Week"todayDate={this.props.todayDate} selected={this.props.startDate} change={this.props.handlePlannedDateChange} />
          <DateInput label="Expected Week"todayDate={this.props.startDate} selected={this.props.expectedDate} change={this.props.handleExpectedDateChange} />


          <div>
            <label htmlFor="cropSelected">
              Material Type
              <select name="materialTypeID" value={this.props.materialTypeID} onChange={this.props.handleChange}>
                  <option value="">Select</option>
                  {this.props.materialTypeList.map(x => (
                      <option key={x.materialTypeCode} value={x.materialTypeID}>
                          {x.materialTypeDescription}
                      </option>
                  ))}
              </select>
            </label>
          </div>
          <div>
            <label htmlFor="cropSelected">
              Material State
              <select name="materialStateID" value={this.props.materialStateID} onChange={this.props.handleChange}>
                <option value="">Select</option>
                  {this.props.materialStateList.map(x => (
                      <option key={x.materialStateCode} value={x.materialStateID}>
                          {x.materialStateDescription}
                      </option>
                  ))}
              </select>
            </label>
          </div>
          <div>
            <label htmlFor="cropSelected">
              Container Type
              <select name="containerTypeID" value={this.props.containerTypeID} onChange={this.props.handleChange}>
              <option value="">Select</option>
                  {this.props.containerTypeList.map(x => (
                      <option key={x.containerTypeCode} value={x.containerTypeID}>
                          {x.containerTypeName}
                      </option>
                  ))}
              </select>
            </label>
          </div>



          <div>
            <label htmlFor="objectID">
              Selected Object ID
              <input
                name="objectID"
                type="text"
                value={this.props.objectID}
                readOnly
                disabled
              />
            </label>
          </div>

          <div>
            <label>Import Level</label>
            <div className="radioSection">
             <label htmlFor="plant" className={importLevel === "PLT" ? 'active' : ''}>
                <input
                  id="plant"
                  type="radio"
                  value="PLT"
                  name="importLevel"
                  checked={importLevel === "PLT"}
                  onChange={this.props.handleChange}
                />
                Plant
              </label>
              <label htmlFor="list" className={importLevel === "LIST" ? 'active' : ''}>
                <input
                  id="list"
                  type="radio"
                  value="LIST"
                  name="importLevel"
                  checked={importLevel === "LIST"}
                  onChange={this.props.handleChange}
                />
                List
              </label>
             {/*
            */}
            </div>
          </div>

          <div>
            <label htmlFor="fileName">
              File Name
              <input
                name="fileName"
                type="text"
                value={this.props.fileName}
                onChange={this.props.handleChange}
                disabled={false}
              />
            </label>
          </div>

          <div className="markContainer">
            <div className="marker">
              <input
                type="checkbox"
                id="isolationModalPhenome"
                name="isolationStatus"
                checked={this.props.isolationStatus}
                onChange={this.props.handleChange}
              />
              <label htmlFor="isolationModalPhenome">Already Isolated</label> {/*eslint-disable-line*/}
            </div>
          </div>

          <div className="markContainer">
            <div className="marker">
              <input
                type="checkbox"
                id="cumulateStatus"
                name="cumulateStatus"
                checked={this.props.cumulateStatus}
                onChange={this.props.handleChange}
              />
              <label htmlFor="cumulateStatus">Cumulate</label> {/*eslint-disable-line*/}
            </div>
          </div>

      </Fragment>
    );
  }
}
export default TwoGB;
