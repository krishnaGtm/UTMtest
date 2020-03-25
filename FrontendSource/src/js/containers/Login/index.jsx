import React from 'react';
import { Redirect } from 'react-router';
import utmLogin from './api';

import './login.scss';

class Login extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      user: 'user@enzazaden.com',
      pwd: 'enzds321',
      redirectToReferrer: false
    };
  }

  handleSubmit = e => {
    e.preventDefault();
    this.login();
  };

  handleChange = e => {
    console.log(e);
  };

  login = () => {
    utmLogin();
  };

  render() {
    const { user, pwd } = this.state;

    // console.log(this.props);

    // const { from } = this.props.location.state || { from: { pathname: "/" } };
    const { from } = { from: { pathname: '/' } };
    const { redirectToReferrer } = this.state;

    if (redirectToReferrer) {
      return <Redirect to={from} />;
    }

    return (
      <div className="loginWrapper">
        <div className="loginContainer">
          <div className="loginTitle">
            <h1>UTM Login</h1>
          </div>
          <form method="POST" action="#" onSubmit={this.handleSubmit}>
            <div className="loginBody">
              <label htmlFor="userEmail">
                User:
                <input
                  name="username"
                  type="text"
                  onChange={this.handleChange}
                  value={user}
                />
              </label>
              <label htmlFor="userPassword">
                Password:
                <input
                  name="password"
                  type="password"
                  onChange={this.handleChange}
                  value={pwd}
                />
              </label>
            </div>
            <div className="loginFooter">
              <button type="submit">Login</button>
              <button type="reset">Reset</button>
            </div>
          </form>
        </div>
      </div>
    );
  }
};
export default Login;
