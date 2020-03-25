import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import Wrapper from '../../../components/Wrapper/wrapper';

class Result extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      configID: props.editData.configID || '',
      crop: props.editData.cropCode || '',
      group: props.editData.configGroup || '',
      email: props.editData.recipients || '',
      errState: false,
      errMsg: 'Please enter valid email address.'
    };
  }

/**
 * Email validation
 * receives array list which is tested with regex for validation
 * @return boolen
 */
  emailValidation = recipients => {
    let validation = true;
    let re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    const emailList = recipients.replace(/\s/g, '').replace(';', ',').split(',');
    emailList.map(e => {
      if (!re.test(String(e).toLowerCase())) {
        validation = false;
      }
      return null;
    });
    return validation;
  };
  
  handleAdd = () => {
    const { configID, crop: cropCode, group: configGroup, email: recipients} = this.state;
    const { mode } = this.props;

    if(this.emailValidation(recipients)) {
      if (mode === 'add') {
        this.props.onAppend(configID, cropCode, configGroup, recipients);
      }
      if (mode === 'edit') {
        this.props.onAppend(configID, cropCode, configGroup, recipients);
      }
      this.setState({ errState: false });
      this.props.close('');
    } else {
      this.setState({ errState: true });
    }
    return null;
  }
  handleChange = e => {
    const { target } = e;
    const { value, name } = target;

    this.setState({
      [name]: value
    });
  };

  cropUI = () => {
    const { mode } = this.props;
    if (mode !== 'edit') {
      return (
        <select
          name="crop"
          value={this.state.crop}
          onChange={this.handleChange}
        >
          <option value="*">All Crops</option>
          {this.props.crops.map(crop => (
            <option key={crop} value={crop}>
              {crop}
            </option>
          ))}
        </select>
      );
    }
    return (
      <input
        name="group"
        type="text"
        value={this.state.crop}
        onChange={() => {}}
        disabled
      />
    );
  }

  render() {
    const { mode } = this.props;
    const { errState, errMsg } = this.state;
    const title = mode === 'edit' ? 'Edit ' : 'Add ';
    const buttonName = mode === 'edit' ? 'Update ' : 'Save';

    return (
      <Wrapper>
        <div className="modalContent">
          <div className="modalTitle">
            <i className="demo-icon icon-plus-squared info" />
            <span>{title} Mail Config</span>
            <i
              role="button"
              className="demo-icon icon-cancel close"
              onClick={() => this.props.close('')}
              title="Close"
            />
          </div>
          {/*<div className="modalBody"></div>*/}
          <div className="modelsubtitle">
            <div>
              <label htmlFor="trait">Group</label> {/*eslint-disable-line*/}
              <input
                name="group"
                type="text"
                value={this.state.group}
                onChange={() => {}}
                disabled
              />
            </div>
            <div>
              <label>Crop</label>{/*eslint-disable-line*/}
              {this.cropUI()}
            </div>


            <div>
              <label htmlFor="determination">
                Email
                {errState && <span style={{paddingLeft: '5px', color: 'red'}}>{errMsg}</span>}
              </label>{/*eslint-disable-line*/}
              <textarea
                name="email"
                type="text"
                value={this.state.email}
                onChange={this.handleChange}
                style={{'minHeight':'100px'}}
              />
            </div>
          </div>

          <div className="modalFooter">
            &nbsp;&nbsp;
            <button
              onClick={this.handleAdd}
            >
              {buttonName}
            </button>
          </div>
        </div>
      </Wrapper>
    );
  }
}

Result.defaultProps = {
  mode: '',
  crops: [],
  editData: {}
};
Result.propTypes = {
  close: PropTypes.func.isRequired,
  mode: PropTypes.string,
  crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  editData: PropTypes.object, // eslint-disable-line react/forbid-prop-types
};

export default Result;
