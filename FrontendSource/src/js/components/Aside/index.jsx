import React from 'react';
import { NavLink, withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import './aside.scss';

import { couputeRoute } from '../../routes';

function CustomLink({ to, label }) {
  return (
    <li>
      <NavLink exact to={to} activeClassName="active">
        <i className="icon icon-right-1" />
        {label}
      </NavLink>
    </li>
  );
}
CustomLink.propTypes = {
  to: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired
};

const Aside = ({ role, testTypeID }) => {
  // const isThreeGBTestTypeID = testTypeID === 4 || testTypeID === 5;
  // ##  Only UTM user can the menus, So, commun menu are restricited checking possible users can access it
  // const requestTestRole = role.includes('requesttest');
  // const manageMasterDataUTMRole = role.includes('managemasterdatautm');
  // const handleLabCpapacityRole = role.includes('handlelabcapacity');
  // const adminRole = role.includes('admin');
  // const platePlansRole = requestTestRole || handleLabCpapacityRole;
  // const utmCommonRole = requestTestRole || manageMasterDataUTMRole || adminRole;

  return (
    <aside>
      <h3>Menu</h3>
      <ul>
        {couputeRoute(role, testTypeID).map((x, i) =><CustomLink key={i} to={i===0 ? '/' : x.to} label={x.name} />)}
      </ul>
    </aside>
  );
};

const mapStateToProps = state => ({
  testTypeID: state.rootTestID.testTypeID,
  role: state.user.role
});

Aside.defaultProps = {
  role: [],
  testTypeID: 1
};
Aside.propTypes = {
  testTypeID: PropTypes.number,
  role: PropTypes.array // eslint-disable-line
};
export default withRouter(
  connect(
    mapStateToProps,
    null
  )(Aside)
);
