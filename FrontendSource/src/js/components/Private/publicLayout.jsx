import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import Aside from '../Aside';
import Header from '../Header';

const PublicLayout = ({ children }) => (
  <div>
    <Aside />
    <div className="bodyWrap">
      <Header />
      <div>
        <div className="main">{children}</div>
      </div>
    </div>
  </div>
);

const mapStateToProps = state => ({
  sideStatus: state.sidemenuReducer
});
const mapDispatchToProps = dispatch => ({
  resetAll: () => dispatch({ type: 'RESETALL' })
});

PublicLayout.propTypes = {
  // resetAll: PropTypes.func.isRequired,
  // sideStatus: PropTypes.bool.isRequired,
  // children: PropTypes.element.isRequired,
  // role: PropTypes.array // eslint-disable-line react/forbid-prop-types
};
export default connect(mapStateToProps, mapDispatchToProps)(PublicLayout);
// export default Layout;
