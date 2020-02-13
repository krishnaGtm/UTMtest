import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import './remark.scss';

import { remarkHide, remarkSave } from './remarkAction';

class Remarks extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      testID: props.testID,
      text: props.remark,
      statusCode: props.statusCode
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.remark !== this.props.remark) {
      this.setState({ text: nextProps.remark || '' });
    }
    if (nextProps.testID !== this.props.testID) {
      this.setState({ testID: nextProps.testID });
    }
    if (nextProps.statusCode !== this.props.statusCode) {
      this.setState({ statusCode: nextProps.statusCode });
    }
  }

  componentDidUpdate() {
    if (this.remarksInput) {
      this.remarksInput.focus();
    }
  }

  change = e => {
    if (this.state.statusCode < 200) {
      this.setState({text: e.target.value});
    }
  };

  _close = () => {
    this.setState({ text: this.props.remark });
    this.props.close();
  };

  _save = () => {
    const { testID } = this.state;
    let { text } = this.state;
    text = text.trim();
    this.props.save(testID, text);
  };

  render() {
    const btnStat = this.state.statusCode < 200;
    const { display } = this.props;
    const title = 'Remarks';

    if (!display) {
      return null;
    }

    return (
      <div className="remarksWrap">
        <div className="remarksContent">
          <div className="remarksTitle">
            <i className="demo-icon icon-commenting info" />
            <span>{title}</span>
            <i
              role="presentation"
              className="demo-icon icon-cancel close"
              onClick={this._close}
              title="Close"
            />
          </div>
          <div className="remarksBody">
            <textarea
              value={this.state.text}
              ref={input => {
                this.remarksInput = input;
                return null;
              }}
              onChange={this.change}
            />
          </div>
          <div className="remarksFooter">
            {btnStat && (
              <button onClick={this._save} title="Save">
                Save
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }
}

const mapState = state => ({
  display: state.remarks,
  testID: state.rootTestID.testID,
  remark: state.rootTestID.remark || '',
  statusCode: state.rootTestID.statusCode
});
const mapDispatch = dispatch => ({
  close() {
    dispatch(remarkHide());
  },
  save(testID, remark) {
    dispatch(remarkSave(testID, remark));
    dispatch(remarkHide());
  }
});
Remarks.defaultProps = {
  testID: '',
  remark: '',
  statusCode: ''
};
Remarks.propTypes = {
  display: PropTypes.bool.isRequired,
  close: PropTypes.func.isRequired,
  save: PropTypes.func.isRequired,
  testID: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  statusCode: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  remark: PropTypes.string
};
export default connect(mapState, mapDispatch)(Remarks);
