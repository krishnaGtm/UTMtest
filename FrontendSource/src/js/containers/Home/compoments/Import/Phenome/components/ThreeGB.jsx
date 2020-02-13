import React, { Fragment } from 'react';

class ThreeGB extends React.Component {
  render() {
    return (
      <Fragment>
          <div>
            <label htmlFor="cropSelected">
              Crops
              <select
                name="cropSelected"
                onChange={this.props.handleChange}
              >
                <option value="">Select</option>
                {this.props.crops.map(c => (
                  <option value={c} key={c}>
                    {c}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <div>
            <label htmlFor="breedingStationSelected">
              Br.Station
              <select
                name="breedingStationSelected"
                onChange={this.props.handleChange}
              >
                <option value="">Select</option>
                {this.props.breedingStation.map(b => (
                  <option
                    value={b.breedingStationCode}
                    key={b.breedingStationCode}
                  >
                    {b.breedingStationCode}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <div>
            <label htmlFor="threeGBTaskID">
              Project List
              <select
                name="threeGBTaskID"
                onChange={this.props.handleChange}
                disabled={
                  this.props.cropSelected === '' || this.props.breedingStationSelected === ''
                }
                value={this.props.threeGBTaskID}
              >
                <option value="">Select</option>
                {this.props.threegbList.map(b => (
                  <option value={b.threeGBTaskID} key={b.threeGBTaskID}>
                    {b.week} - {b.threeGBProjectcode}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <div>
            <label htmlFor="fileName">
              File Name
              <input
                name="fileName"
                type="text"
                value={this.props.fileName}
                disabled={true}
              />
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
      </Fragment>
    );
  }
}
export default ThreeGB;
