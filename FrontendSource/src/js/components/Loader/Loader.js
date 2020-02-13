import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import './loader.scss';

const Loader = ({ status }) => {
  if (!status) {
    return <span />;
  }

  return (
    <div className="loaderWrapper active">
      <div className="loader">
        <i className="demo-icon icon-spin6 animate-spin" />
      </div>
    </div>
  );
};

const mapStateToProps = state => ({
  status: state.loader
});

Loader.propTypes = {
  status: PropTypes.number.isRequired
};
export default connect(mapStateToProps, null)(Loader);
