import React from 'react';
import './loginForm.scss';
import utmLogin from '../../containers/Login/api';

class LoginForm extends React.Component {
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
    if (!this.props.visibility) {
      return null;
    }
    return (
      <div className="loginFormWrap">
        <form method="POST" action="#" onSubmit={this.handleSubmit}>
          <div className="loginFormContent">
            <div className="loginFormTitle">
              <i className="demo-icon icon-ok-circled ok"/>
              <span>Login</span>
              <i
                className="demo-icon icon-cancel close"
                role="button"
                onKeyDown={() => {}}
                tabIndex="0"
                onClick={this.props.close}
              />
            </div>
            <div className="loginFormBody">
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
                  type="text"
                  onChange={this.handleChange}
                  value={pwd}
                />
              </label>
            </div>
            <div className="errorAction">
              <button type="submit">Login</button>
              <button type="reset">Reset</button>
            </div>
          </div>
        </form>
      </div>
    );
  }
}
export default LoginForm;
