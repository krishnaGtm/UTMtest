import React from 'react';
import PropTypes from 'prop-types';

const Error = ({ errCode, errMsg, messageType, error, close }) => {
  let title = (
    <div className="title">
      <i className="demo-icon icon-attention" />
      Error: {errCode}
    </div>
  );

  let arrayMsg = '';
  let isArr = false;
  if (Array.isArray(errMsg)) {
    isArr = true;
    arrayMsg = errMsg.map((er, i) => <li key={i}>{er}</li>); // eslint-disable-line
  }

  if (messageType === 1) {
    title = (
      <div className="title">
        <i className="demo-icon icon-info" />
        Info:
      </div>
    );
  }

  if (error) {
    return (
      <div className="errorWrap">
        <div className="errorContent">
          <div className="errorTitle">
            {title}
            <div className="action">
              <i
                className="demo-icon icon-cancel"
                onClick={close}
                role="button"
                tabIndex="0"
                onKeyDown={() => {}}
              />
            </div>
          </div>
          <div className="errorBody">
            {isArr ? (
              <ul style={{ paddingLeft: '20px' }}>{arrayMsg}</ul>
            ) : (
              errMsg
            )}
          </div>
        </div>
      </div>
    );
  }
  return null;
};
Error.defaultProps = {
  errCode: '',
  errMsg: [],
  messageType: null,
  error: false,
  close: () => {}
};
Error.propTypes = {
  errCode: PropTypes.string,
  errMsg: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  messageType: PropTypes.number,
  error: PropTypes.bool,
  close: PropTypes.func
};
export default Error;
