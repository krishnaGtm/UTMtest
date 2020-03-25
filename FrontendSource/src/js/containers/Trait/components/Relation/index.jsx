import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Autosuggest from 'react-autosuggest';

import Wrapper from '../../../../components/Wrapper/wrapper';
import { fetchDetermination, fetchTrait } from '../../action';
import './relation.scss';

class Relation extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // sourceList: sources,
      sourceSelected: props.editData.source || 'Phenome',

      // cropList: props.crop,
      cropSelected: props.editData.cropCode || '',

      traitSelected: props.editData.traitID || '',
      // traitList: props.trait,
      // traitSuggestions: [],
      traitValue: props.editData.traitLabel || '',

      determinationSelected: props.editData.determinationID || '',
      // determinationList: props.determination,
      determinationSuggestions: [],
      determinationValue: props.editData.determinationName || ''
      // editData: props.editData
    };
  }
  componentDidMount() {
    // no need to select crop 2018 05 4
    // this.props.fetchCrop();
    /* const { editData, mode } = this.props;
    if (mode === 'edit') {
      this.setState({
        cropSelected: editData.cropCode,
        determinationValue: editData.determinationName || '',
        determinationSelected: editData.determinationID || '',
        traitValue: editData.traitLabel,
        traitSelected: editData.traitID,
        sourceSelected: editData.source
      });
    } */
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.determination) {
      this.setState({
        determinationSuggestions: nextProps.determination
      });
    }
  }

  onDeterminationChange = (event, { newValue }) => {
    this.setState({
      determinationValue: newValue
    });
  };
  determinationSuggestionValue = value => {
    this.setState({
      determinationSelected: value.determinationID
    });
    return value.determinationName;
  };
  determinationSuggestion = suggestion => (
    <div>{suggestion.determinationName}</div>
  );
  determinationFetchReq = ({ value }) => {
    const _this = this;
    const inputValue = value.trim().toLowerCase();
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      _this.determinationFetch(inputValue);
    }, 500);
  };
  determinationFetch = value => {
    this.setState({
      determinationSelected: ''
    });
    this.props.fetchDetermination(value, this.state.cropSelected);
  };
  determinationClearReq = () => {
    this.setState({
      determinationSuggestions: []
    });
  };

  validateAdd = () => {
    const {
      // sourceSelected,
      traitValue,
      traitSelected,
      determinationValue,
      determinationSelected
    } = this.state;

    const validation =
      traitValue !== '' &&
      traitSelected !== '' &&
      determinationValue !== '' &&
      determinationSelected !== '';
    return !validation;
  };
  handleAddRelation = () => {
    const _this = this;
    const {
      traitValue,
      sourceSelected,
      traitSelected,
      determinationSelected
    } = this.state;
    /**
     * I = add, U = update, D = remove
     */
    let action = 'I';
    if (this.props.mode === 'edit') {
      action = 'U';
      /**
       * if relationID = 0
       * 22/8/2018
       * relationID receives null so or condition added
       * consider as add
       */
      if (
        this.props.editData.relationID === 0 ||
        this.props.editData.relationID === null
      ) {
        action = 'I';
      }
    }

    let obj = {
      traitID: traitSelected,
      traitName: traitValue,
      determinationID: determinationSelected,
      source: sourceSelected,
      action
    };

    /**
     * in edit mode passing record
     */
    if (this.props.mode === 'edit') {
      obj = Object.assign(
        {
          relationID: _this.props.editData.relationID
        },
        obj
      );
    }

    this.props.onAppend(obj);
    this.props.close('');

    this.setState({
      determinationSelected: '',
      determinationValue: '',
      traitSelected: '',
      traitValue: ''
    });
  };

  render() {
    const {
      sourceSelected,
      cropSelected,
      // traitSuggestions,
      traitValue,
      determinationSuggestions,
      determinationValue
    } = this.state;

    const showFields = cropSelected !== '' && sourceSelected !== '';

    const determinationInput = {
      placeholder: 'Select Determination',
      value: determinationValue,
      onChange: this.onDeterminationChange
    };

    const buttonName =
      this.props.mode === 'edit' ? 'Update Relation' : 'Add Relation';

    return (
      <Wrapper>
        <div className="modalContent">
          <div className="modalTitle">
            <i className="demo-icon icon-plus-squared info" />
            <span>Relation</span>
            <i
              role="presentation"
              className="demo-icon icon-cancel close"
              onClick={() => this.props.close('')}
              title="Close"
            />
          </div>
          <div className="modalBody">
            <div>
              <label>Crop</label>{/*eslint-disable-line*/}
              <input type="text" value={this.state.cropSelected} disabled />
            </div>

            {showFields && (
              <div>
                <label htmlFor="trait">Traits</label> {/*eslint-disable-line*/}
                <input type="text" value={traitValue} disabled />
              </div>
            )}

            {showFields && (
              <div>
                <label htmlFor="determination">Determination</label>{/*eslint-disable-line*/}
                <Autosuggest
                  suggestions={determinationSuggestions}
                  onSuggestionsFetchRequested={this.determinationFetchReq}
                  onSuggestionsClearRequested={this.determinationClearReq}
                  getSuggestionValue={this.determinationSuggestionValue}
                  renderSuggestion={this.determinationSuggestion}
                  inputProps={determinationInput}
                />
              </div>
            )}
            <div>
              <label htmlFor="">&nbsp;</label>{/*eslint-disable-line*/}
              <div>
                <button
                  disabled={this.validateAdd()}
                  onClick={this.handleAddRelation}
                >
                  {buttonName}
                </button>
              </div>
            </div>
          </div>

          <div className="modalFooter" />
        </div>
      </Wrapper>
    );
  }
}

const mapState = state => ({
  crop: state.traitRelation.crop,
  trait: state.traitRelation.trait,
  determination: state.traitRelation.determination,
  relation: state.traitRelation.relation
});
const mapDispatch = dispatch => ({
  fetchTrait: (traitName, cropCode, sourceSelected) =>
    dispatch(fetchTrait(traitName, cropCode, sourceSelected)),
  fetchDetermination: (determinationName, cropCode) =>
    dispatch(fetchDetermination(determinationName, cropCode))
});

Relation.defaultProps = {
  determination: [],
  editData: {},
  mode: ''
};
Relation.propTypes = {
  determination: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  close: PropTypes.func.isRequired,
  onAppend: PropTypes.func.isRequired,
  fetchDetermination: PropTypes.func.isRequired,
  editData: PropTypes.object, // eslint-disable-line
  mode: PropTypes.string
};
export default connect(
  mapState,
  mapDispatch
)(Relation);
