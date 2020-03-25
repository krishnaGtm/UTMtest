/**
 * Created by sushanta on 3/13/18.
 */
import React from 'react';
import PropTypes from 'prop-types';
import BarcodeSvg from './BarcodeSvg';

const Barcode = ({ legend, title, barcode }) => (
  <div className="plateTitle">
    <fieldset>
      <legend>&nbsp;{legend}&nbsp;</legend>
      <div>
        <h4>{title}</h4>
      </div>
      <BarcodeSvg barcode={barcode} />
    </fieldset>
  </div>
);

Barcode.propTypes = {
  legend: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  barcode: PropTypes.string.isRequired
};

export default Barcode;
