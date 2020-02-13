import React from 'react';

class Exist extends React.Component {
  render() {
    return (
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
    );
  }
}
export default Exist;
