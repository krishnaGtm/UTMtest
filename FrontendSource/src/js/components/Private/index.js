import React from 'react';
import { Route, withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import PublicLayout from './publicLayout.jsx';

const PrivateRoute = ({ component: Test, ...rest }) => (
  <Route
    {...rest}
    render={props => (
        <div>
          <PublicLayout>
            <Test {...props} />
          </PublicLayout>
        </div>
    )}
  />
);

const mapState = state => ({ auth: state.authenticated });
export default withRouter(connect(mapState, null)(PrivateRoute));
