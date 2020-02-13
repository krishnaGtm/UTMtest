import React from 'react';
import PropTypes from 'prop-types';
import autoBind from 'auto-bind';

import './confirmBox.scss';

class ConfirmBox extends React.Component {
  constructor(props) {
    super(props);
    autoBind(this);
  }
  componentDidMount() {
    this.focusButton();
  }
  focusButton() {
    this.buttonType.focus();
  }
  ul = message => {
    return (
      <ul>
        {message.map(x => <li key={x}>{x}</li>)}
      </ul>
    );
  }
  render() {
    const { click, message } = this.props;
    return (
      <div className="confirmWrap">
        <div className="confirmContent ">
          <div className="confirmTitle ">
            <i className="demo-icon icon-info-circled info" />
            <span>Verification</span>
          </div>
          <div className="confirmBody">
            {
              Array.isArray(message) ? this.ul(message) : message
            }
          </div>
          <div className="errorAction">
            <button onClick={() => click(true)}>Yes</button>
            <button
              ref={button => {
                this.buttonType = button;
              }}
              onClick={() => click(false)}
            >
              No
            </button>
          </div>
        </div>
      </div>
    );
  }
}

ConfirmBox.defaultProps = {
  message: ''
};

ConfirmBox.propTypes = {
  click: PropTypes.func.isRequired,
  message: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.array
  ])
};

export default ConfirmBox;
