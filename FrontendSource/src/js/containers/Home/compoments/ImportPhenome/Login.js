/**
 * Created by sushanta on 4/12/18.
 */
import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { phenomeLogin } from '../../actions/phenome';
import './login.scss';

class Login extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      user: '',
      pwd: ''
    };
  }

  handleSubmit = () => {
    const { user, pwd } = this.state;
    if (user && pwd) this.props.phenomeLogin('', user, pwd);
  };
  handleReset = () => {
    this.setState({
      user: '',
      pwd: ''
    });
  };
  handleUserChange = e => {
    this.setState({
      user: e.target.value
    });
  };
  handlePwdChange = e => {
    this.setState({
      pwd: e.target.value
    });
  };
  render() {
    const { user, pwd } = this.state;
    if (this.props.isLoggedIn) return null;
    return (
      <div className="phenome-login">
        <span className="login-title">Phenome Login</span>
        <div className="body">
          <label htmlFor="userEmail">
            User:
            <input
              name="username"
              type="text"
              onChange={this.handleUserChange}
              value={user}
            />
          </label>
          <label htmlFor="userPassword">
            Password:
            <input
              name="password"
              type="password"
              onChange={this.handlePwdChange}
              value={pwd}
            />
          </label>
        </div>
        <div className="action">
          <button onClick={this.handleSubmit} type="submit">
            Login
          </button>
          <button onClick={this.handleReset} type="reset">
            Reset
          </button>
        </div>
      </div>
    );
  }
}

const mapStateToProps = state => ({
  isLoggedIn: state.phenome.isLoggedIn
});
const mapDispatchToProps = {
  phenomeLogin
};

Login.propTypes = {
  isLoggedIn: PropTypes.bool.isRequired,
  phenomeLogin: PropTypes.func.isRequired
};

export default connect(mapStateToProps, mapDispatchToProps)(Login);
