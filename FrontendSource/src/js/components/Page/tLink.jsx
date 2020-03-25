import React from 'react';
import PropTypes from 'prop-types';

const TLink = ({ page, click, label, active }) => {
  if (active === 'blank') return <li>{label}</li>;

  if (active) return <li onClick={() => click(page)}>{label}</li>; // eslint-disable-line

  return <li className="noLink">{label}</li>;
};

TLink.propTypes = {
  page: PropTypes.number.isRequired,
  click: PropTypes.func.isRequired,
  label: PropTypes.string.isRequired,
  active: PropTypes.any.isRequired // eslint-disable-line 
};

export default TLink;
