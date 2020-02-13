/* eslint-disable jsx-a11y/label-has-for */
import React from 'react';
import PropTypes from 'prop-types';
import './fixRow.scss';

class Fixrow extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      fixValue: ''
    };
    this.pattern = /^\d{0,6}$/;
  }

  componentDidMount() {
    this.nameInput.focus();
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.visibility !== this.props.visibility) {
      this.setState({ fixValue: '' });
    }
  }
  // console.log(visibility);
  toSave = () => {
    const { fixValue } = this.state;
    this.props.focusApply(fixValue);
  };
  changeValue = e => {
    if (e.target.value > 0) {
      const tt = this.pattern.test(e.target.value);
      if (tt) {
        this.setState({fixValue: e.target.value});
      }
    }
  };
  render() {
    const { visibility, close, keyName } = this.props;
    const { fixValue } = this.state;

    // const t = visibility ? style.wrapper : style.hidden;
    return (
      <div
        className="confirmWrap"
        // style={style.wrapper}
        style={{
          display: `${visibility ? '' : 'none'}`
        }}
      >
        <div className="applyToAll">
          <div className="confirmTitle ">
            <i className="demo-icon icon-info-circled info" />
            <span>Apply to all</span>
            <i
              role="presentation"
              className="demo-icon icon-cancel close"
              onClick={close}
              title="Close"
            />
          </div>

          <div className="confirmBody">
            <div>
              <label htmlFor="materialState">{keyName}</label>
              <input
                name="materialState"
                id="materialState"
                type="number"
                ref={input => {
                  this.nameInput = input;
                }}
                value={fixValue}
                onChange={this.changeValue}
              />
            </div>
          </div>

          <div className="errorAction">
            <div>
              <button onClick={this.toSave}>Apply</button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
Fixrow.defaultProps = {
  keyName: ''
};
Fixrow.propTypes = {
  visibility: PropTypes.bool.isRequired,
  close: PropTypes.func.isRequired,
  focusApply: PropTypes.func.isRequired,
  keyName: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
};
export default Fixrow;
