import React from 'react';
import { withRouter } from 'react-router-dom'; // NavLink,
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { sidemenuToggle } from '../../action';
import './header.scss';

// , role, testTypeID
// const isThreeGBTestTypeID = testTypeID === 4 || testTypeID === 5;
const Header = ({ sideStatus, onclick }) => (
  <header>
    <div className={!sideStatus ? 'headBar' : 'headBar active'}>
      <div className="toggleBtn">
        <button onClick={onclick}>
          <i className="icon icon-menu" />
          <i className="icon icon-down" />
        </button>
      </div>
      <div className="title">UTM</div>
      <nav>
        <div className="user" title={window.userContext.name}>
          <i className="icon icon-user" />
          <span>{window.userContext.name}</span>
        </div>
      </nav>
    </div>
  </header>
);

const mapStateToProps = state => ({
  sideStatus: state.sidemenuReducer,
  role: state.user.role,
  testTypeID: state.rootTestID.testTypeID
});
const mapDispatchToProps = dispatch => ({
  onclick: () => dispatch(sidemenuToggle())
});
// Header.defaultProps = {
//   // role: []
//   // testTypeID: 1
// };
Header.propTypes = {
  sideStatus: PropTypes.bool.isRequired,
  onclick: PropTypes.func.isRequired
};
// testTypeID: PropTypes.number,
// role: PropTypes.array // eslint-disable-line
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Header));
