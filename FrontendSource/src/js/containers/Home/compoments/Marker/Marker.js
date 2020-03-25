/**
 * Created by sushanta on 3/13/18.
 */
import React from 'react';
import PropTypes from 'prop-types';

class Marker extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected
    };
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.selected !== this.props.selected) {
      this.setState({
        selected: nextProps.selected
      });
    }
  }
  render() {
    const { onChange, determinationID, columnLabel } = this.props;
    const { selected } = this.state;
    return (
      <div className="marks">
        <input
          name={`box_${determinationID}`}
          id={`box_${determinationID}`}
          type="checkbox"
          checked={selected}
          onChange={onChange}
        />
        <label htmlFor={`box_${determinationID}`}>{columnLabel}</label> {/*eslint-disable-line*/}
      </div>
    );
  }
}

Marker.propTypes = {
  selected: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
  determinationID: PropTypes.number.isRequired,
  columnLabel: PropTypes.string.isRequired
};
export default Marker;
