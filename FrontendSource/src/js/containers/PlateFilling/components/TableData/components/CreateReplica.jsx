/**
 * Created by sushanta on 3/2/18.
 */
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import './createReplica.css';

class CreateReplica extends Component {
  constructor(props) {
    super(props);
    this.state = {
      collationStatus: 'collated',
      noOfReplicate: 1,
      validationError: false
    };
  }

  handleCollationStatusChange = e => {
    this.setState({ collationStatus: e.target.value });
  };
  handleReplicateNumberChange = e => {
    let { value } = e.target;
    if (value > 5) {
      value = 5;
    }
    if (value < 1) {
      value = 1;
    }
    this.setState({
      validationError: false,
      noOfReplicate: value
    });
  };
  handleOKBtnClick = () => {
    if (this.state.noOfReplicate > 5) {
      this.setState({ validationError: true });
      return;
    }
    let selectedMaterialsIDs = [];
    this.props.data.map((d, i) => {
      if (this.props.selectedIndexes.includes(i)) {
        selectedMaterialsIDs.push(d.materialID);
      }
      return null;
    });
    selectedMaterialsIDs = [...new Set(selectedMaterialsIDs)]; // remove duplicates
    this.props.dispatch({
      type: 'CREATE_REPLICA',
      data: {
        testID: this.props.testID,
        noOfReplicate: this.state.noOfReplicate,
        collated: this.state.collationStatus === 'collated',
        replicateMaterial: selectedMaterialsIDs
      }
    });
    this.props.closeModal();
    this.props.resetSelectedArray(1, false, true);
    this.setState({
      noOfReplicate: 1,
      collationStatus: 'collated'
    });
  };

  render() {
    const { visibility, closeModal } = this.props;
    return (
      <div
        className="create-replica-modal"
        style={{
          display: `${visibility ? 'block' : 'none'}`
        }}
      >
        <div className="create-replica-modal-content">
          <div className="create-replica-model-header">
            <i className="icon icon-docs" />
            <span
              role="presentation"
              className="create-replica-modal-close"
              onClick={closeModal}
            >
              &times;
            </span>
            <h4>Create Replica</h4>
          </div>
          <div className="create-replica-modal-body">
            <div className="create-replica-modal-row">
              <input
                style={{ flex: 1, marginRight: '10px' }}
                type="number"
                value={this.state.noOfReplicate}
                min={1}
                max={5}
                onChange={this.handleReplicateNumberChange}
              />
              <div className="create-replica-radios-container">
                <div className="create-replica-radio-btn-holder">
                  <span>Collated</span>
                  <input
                    type="radio"
                    name="status"
                    value="collated"
                    checked={this.state.collationStatus === 'collated'}
                    onChange={this.handleCollationStatusChange}
                  />
                </div>
                <div className="create-replica-radio-btn-holder">
                  <span>Un-Collated</span>
                  <input
                    type="radio"
                    name="status"
                    value="uncollated"
                    checked={this.state.collationStatus === 'uncollated'}
                    onChange={this.handleCollationStatusChange}
                  />
                </div>
              </div>
            </div>
            <div className="create-replica-modal-hint">
              <b>Hints:</b>
              <p>Uncollated (1,1,1 2,2,2 3,3,3)</p>
              <p>Collated (1,2,3 1,2,3 1,2,3)</p>
            </div>
            <div className="create-replica-modal-action-buttons">
              {this.state.validationError && (
                <span className="create-replica-modal-validation-error">
                  Number of replicas cannot be greater than 5.
                </span>
              )}
              <button
                className="create-replica-modal-action-button"
                onClick={this.handleOKBtnClick}
              >
                OK
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
CreateReplica.defaultProps = {
  data: [],
  selectedIndexes: [],
  testID: ''
};
CreateReplica.propTypes = {
  data: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  selectedIndexes: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  testID: PropTypes.number || PropTypes.string,
  visibility: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
  resetSelectedArray: PropTypes.func.isRequired,
  dispatch: PropTypes.func.isRequired
};
export default connect()(CreateReplica);
