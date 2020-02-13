import React from 'react';
import { connect } from 'react-redux';
import shortid from 'shortid';
import PropTypes from 'prop-types';
import Wrapper from '../../../../components/Wrapper/wrapper';
import './checklist.scss';

const List = ({ checkList, close }) => (
  <Wrapper>
    <div className="validationList modalContent">
      <div className="modalTitle">
        <i className="demo-icon icon-ok-circled warn" />
        <span>Not Mapped Determination List</span>
        <i
          role="presentation"
          className="demo-icon icon-cancel close"
          onClick={() => close(false)}
          title="Close"
        />
      </div>
      <div className="modalBody">
        <table className={checkList.length < 2 ? 'noScroller' : 'scroller'}>
          <thead>
            <tr>
              <th>Test Name</th>
              <th>ID</th>
              <th>Name</th>
              <th>Value</th>
            </tr>
          </thead>
          <tbody>
            {checkList.map(d => (
              <tr key={shortid.generate()}>
                <td>{d.testName}</td>
                <td>{d.determinationID}</td>
                <td>{d.determinationName}</td>
                <td>{d.determinationValue}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  </Wrapper>
);

List.defaultProps = {
  checkList: []
};
List.propTypes = {
  checkList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  close: PropTypes.func.isRequired
};
const mapState = state => ({
  checkList: state.traitResult.checkValidation
});
export default connect(
  mapState,
  null
)(List);
