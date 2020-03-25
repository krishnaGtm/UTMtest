import React from 'react';
import { BrowserRouter, Switch } from 'react-router-dom';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

// this one is not in route
import PrintList from './PunchList/PunchList';

import NoMatch from './NoMatch';

import Loader from '../components/Loader/Loader';
import Remarks from '../components/Remarks/Remark';
import AppError from '../components/Error';
import Notification from '../components/Notification/Notification';

import PrivateRoute from '../components/Private';
// import './app.scss';
import { couputeRoute } from '../routes';

const styles = {
  initLoader: {
    background: 'rgba(0, 0, 0, 0.34)',
    height: '100%',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  },
  loader: {
    width: '60px',
    height: '60px',
    background: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    display: 'flex',
    borderRadius: '100%'
  }
};

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblCellWidth: 100,
      tblWidth: 1100,
      tblHeight: 500,
      login: false
    };
    props.fetchToken();
  }

  resize = () => {
    const width = window.innerWidth;
    this.setState({
      tblWidth: width,
      tableHeight: window.document.body.offsetHeight
    });
  };

  render() {
    const { sideStatus, role, token, testTypeID } = this.props;

    // console.log(token);

    if (token === null) {
      return (
        <div style={styles.initLoader}>
          <div style={styles.loader}>
            <i className="demo-icon icon-spin6 animate-spin" />
          </div>
        </div>
      );
    }

    const newComp = couputeRoute(role, testTypeID);
    return (
      <BrowserRouter>
        <div className="base" data-aside={sideStatus}>
          <Switch>
            {newComp.map((x, i) => <PrivateRoute key={i} exact path={i===0 ? '/' : x.to} component={x.comp} />)}
            <PrivateRoute exact path="/punchlist" component={PrintList} />
            <PrivateRoute exact path="/samplelist" component={PrintList} />
            <PrivateRoute component={NoMatch} />
          </Switch>
          <Loader />
          <Notification />
          <AppError {...this.state} close={this._errorClose} />
          <Remarks />
        </div>
      </BrowserRouter>
    );
  }
}

const mapStateToProps = state => ({
  sideStatus: state.sidemenuReducer,
  role: state.user.role,
  token: state.user.token,
  testTypeID: state.rootTestID.testTypeID
});
const mapDispatchToProps = dispatch => ({
  resetAll: () => dispatch({ type: 'RESETALL' }),
  fetchToken: () => dispatch({ type: 'FETCH_TOKEN' })
});
App.defaultProps = {
  role: [],
  testTypeID: 0
};
App.propTypes = {
  resetAll: PropTypes.func.isRequired,
  testTypeID: PropTypes.number,
  sideStatus: PropTypes.bool.isRequired,
  role: PropTypes.array // eslint-disable-line react/forbid-prop-types
};
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App);
