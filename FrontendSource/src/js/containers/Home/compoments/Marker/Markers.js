import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import autoBind from 'auto-bind';
import { markerToggle, markerAssign } from './markerAction';
import { checkStatus } from '../../../../helpers/helper';
import Marker from './Marker';

class Markers extends React.Component {
  constructor(props) {
    super(props);
    autoBind(this);
  }
  preAssignMarker() {
    const determinationsChecked = [];
    this.props.markers.map(d => {
      if (d.selected === true) determinationsChecked.push(d.determinationID);
      return null;
    });

    const { testID, testTypeID, filter } = this.props;
    this.props.assignMarker(testID, testTypeID, filter, determinationsChecked);
  }

  render() {
    const btnStat = checkStatus(this.props.statusCode, 'CONFIRM');
    const { status, show, markers, collapse, toggleClick } = this.props;
    if (!status) return null;
    const assignChecked = markers.some(mark => mark.selected === true);
    return (
      <div className="trow marker">
        <div className="tcell">
          <div className="markTitle">
            <button
              onClick={this.preAssignMarker}
              disabled={btnStat || !assignChecked}
              title="Assign marker"
              className="icon"
            >
              <i className="icon icon-ok-squared" />
              Assign Marker
            </button>
            {/* <button onClick={this.props.goto} disabled={!gotoCheck} title="Plate filling">Plate Filling</button> */}

            <button
              className="visible"
              title="Toggle marker"
              onClick={collapse}
            >
              <i
                className={show ? 'icon icon-up-open' : 'icon icon-down-open'}
              />
            </button>
          </div>
          {show ? (
            <div className="markContainer">
              {markers.map(mark => (
                <Marker
                  key={`${mark.determinationID}_${mark.columnLabel}`}
                  {...mark}
                  onChange={() => toggleClick(mark.determinationID)}
                />
              ))}
            </div>
          ) : (
            ''
          )}
        </div>
      </div>
    );
  }
}
const mapStateToProps = (state, ownProps) => ({
  markers: state.assignMarker.marker,
  testID: state.rootTestID.testID,
  testTypeID: state.assignMarker.testType.selected,
  statusCode: state.rootTestID.statusCode,
  filter: state.assignMarker.filter,
  status: ownProps.status,
  show: ownProps.show,
  collapse: ownProps.collapse
});
const mapDispatchToProps = dispatch => ({
  toggleClick: id => {
    dispatch(markerToggle(id));
  },
  assignMarker: (testID, testTypeID, filter, determinationsChecked) => {
    dispatch(markerAssign(testID, testTypeID, filter, determinationsChecked));
  }
});
Markers.defaultProps = {
  statusCode: null,
  testTypeID: null,
  testID: null
};
Markers.propTypes = {
  markers: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  statusCode: PropTypes.number,
  testID: PropTypes.number,
  testTypeID: PropTypes.number,
  assignMarker: PropTypes.func.isRequired,
  toggleClick: PropTypes.func.isRequired,
  collapse: PropTypes.func.isRequired,
  status: PropTypes.bool.isRequired,
  show: PropTypes.bool.isRequired
};
export default connect(mapStateToProps, mapDispatchToProps)(Markers);
