import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

const TestType = ({ testTypeID, testTypeName }) => (
  <option value={testTypeID}>{testTypeName}</option>
);

class TestTypeList extends React.Component {
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

  change = e => {
    const val = e.target.value * 1; // change string to number
    this.props.testType_selected(val);
  };
  render() {
    const { label, testType } = this.props;
    return (
      <div>
        <label>{label}</label> {/*eslint-disable-line*/}
        <select
          disabled={this.props.disabled}
          name="testType"
          value={this.state.selected}
          onChange={this.change}
        >
          {testType.map(test => <TestType key={test.testTypeID} {...test} />)}
        </select>
      </div>
    );
  }
}
const mapStateToProps = (state, ownProps) => ({
  testType: state.assignMarker.testType.list,
  selected: state.assignMarker.testType.selected,
  testID: state.rootTestID.testID,
  label: ownProps.label
});
const mapDispatchToProps = dispatch => ({
  testType_selected: id => {
    dispatch({ type: 'TESTTYPE_SELECTED', id });
    dispatch({ type: 'ROOT_TESTTYPEID', testTypeID: id });
  }
});
TestTypeList.propTypes = {
  selected: PropTypes.bool.isRequired,
  disabled: PropTypes.bool.isRequired,
  label: PropTypes.string.isRequired,
  testType_selected: PropTypes.func.isRequired,
  testType: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};
TestType.propTypes = {
  testTypeID: PropTypes.number.isRequired,
  testTypeName: PropTypes.string.isRequired
};
export default connect(mapStateToProps, mapDispatchToProps)(TestTypeList);
