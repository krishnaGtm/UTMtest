/**
 * Created by sushanta on 3/13/18.
 */
import React from 'react';
import PropTypes from 'prop-types';

const BarcodeSvg = ({ barcode }) => (
  <div className="barcodeWrap">
    <div dangerouslySetInnerHTML={{ __html: barcode }} /> {/*eslint-disable-line*/}
  </div>
);

BarcodeSvg.propTypes = {
  barcode: PropTypes.string.isRequired
};

export default BarcodeSvg;
