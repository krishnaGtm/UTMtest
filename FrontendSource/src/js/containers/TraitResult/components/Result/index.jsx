import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Autosuggest from 'react-autosuggest';

import Wrapper from '../../../../components/Wrapper/wrapper';

import {
  fetchCrop,
  fetchDetermination,
  fetchTrait
} from '../../../Trait/action';
import { getTraitValues, traitValuesReset } from '../../action';

class Result extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      // sourceList: sources,
      sourceSelected: 'Phenome',

      cropList: props.crop,
      cropSelected: props.editData.cropCode || '',

      // traitSelected: props.editData.traitID || '',
      traitSuggestions: [],
      traitValue: props.editData.traitName || '',
      traitType: props.editData.listOfValues || false, // '',

      // determinationSelected: props.editData.determinationID || '',
      // determinationSuggestions: [],
      determinationValue: props.editData.determinationName || '',

      traitName: props.editData.traitValue || '',
      determinationName: props.editData.determinationValue || '',

      traitValuesList: props.traitValues,

      relationID: props.editData.relationID || ''
      // cropTraitID: props.editData.cropTraitID || '',
      // determinationID: props.editData.determinationName || ''
      // editData: props.editData
    };
    // console.log(props);
  }
  componentDidMount() {
    this.props.fetchCrop();
    const { editData, mode } = this.props;
    if (mode === 'edit') {
      const {
        // cropCode,
        // traitName,
        // traitID,
        // determinationName,
        // determinationID,
        // traitValue,
        // determinationValue,
        // relationID,
        cropTraitID,
        listOfValues
      } = editData;
      // console.log(editData);
      if (listOfValues) {
        // this.props.fetchTraitValues(cropCode, traitID);
        this.props.fetchTraitValues(cropTraitID);
      }
      /* this.setState({
        cropSelected: cropCode,
        traitValue: traitName,
        traitSelected: traitID,
        determinationValue: determinationName,
        determinationSelected: determinationID,
        traitName: traitValue,
        determinationName: determinationValue,
        traitType: listOfValues,
        determinationID: determinationName,
        cropTraitID,
        relationID
      }); */
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.crop.length !== this.props.crop.length) {
      this.setState({
        cropList: nextProps.crop
      });
    }
    if (nextProps.trait !== this.props.trait) {
      this.setState({
        // traitList: nextProps.trait,
        traitSuggestions: nextProps.trait
      });
    }
    // if (nextProps.determination !== this.props.determination) {
    //   this.setState({
    //     determinationSuggestions: nextProps.determination
    //   });
    // }
    // if (nextProps.cropTraitID !== this.props.cropTraitID) {
    //   this.setState({
    //     cropTraitID: nextProps.cropTraitID
    //   });
    // }
    if (nextProps.traitValues !== this.props.traitValues) {
      this.setState({
        traitValuesList: nextProps.traitValues
      });
    }
  }
  onTraitChange = (event, { newValue }) => {
    // console.log(newValue);
    this.setState({
      traitValue: newValue
    });
  };
  onDeterminationChange = (event, { newValue }) => {
    this.setState({
      determinationValue: newValue
    });
  };

  traitSuggestionValue = value => {
    // console.log(value);
    const {
      // traitID,
      traitName,
      listOfValues,
      cropTraitID,
      // determinationID,
      determinatioName,
      relationID
    } = value;

    // console.log(this.state.cropSelected, traitID);
    // alert(1);
    if (listOfValues) {
      // alert(2);
      this.props.fetchTraitValues(cropTraitID);
    }

    this.setState({
      // traitSelected: traitID,
      traitType: listOfValues,
      traitValue: '',
      // cropTraitID,
      // determinationID,
      determinationValue: determinatioName,
      relationID
    });
    return traitName;
  };
  traitSuggestion = suggestion => {
    const { traitName } = suggestion;
    return <div>{traitName}</div>;
  };
  traitFetchReq = ({ value }) => {
    this.setState({
      // traitSelected: '',
      traitType: ''
    });
    // console.log(value);
    const _this = this;
    const inputValue = value.trim().toLowerCase();
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      _this.traitFetch(inputValue);
    }, 500);
  };
  traitFetch = value => {
    const { cropSelected, sourceSelected } = this.state;
    // console.log(this.state);
    this.props.fetchTrait(value, cropSelected, sourceSelected);
  };
  traitClearReq = () => {
    this.setState({
      traitSuggestions: []
    });
  };

  determinationSuggestionValue = value => value.determinationName;
  // {
  //   this.setState({
  //     determinationSelected: value.determinationID
  //   });
  //   return value.determinationName;
  // };
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
    // this.setState({
    //   determinationSuggestions: this.suggestionDetermination(value, this.state.determinationList)
    // });
  };
  determinationFetch = value => {
    // this.setState({
    //   determinationSelected: ''
    // });
    this.props.fetchDetermination(value, this.state.cropSelected);
  };
  determinationClearReq = () => {
    // this.setState({
    //   determinationSuggestions: []
    // });
  };

  handleChange = e => {
    const { target } = e;
    const { name, value } = target;

    if (name === 'cropSelected') {
      this.props.resetTraitValues();
      this.setState({
        // determinationSelected: '',
        determinationValue: '',
        // traitSelected: '',
        traitValue: '',
        // traitName: '',
        // determinationName: '',
        traitType: false
      });
    }
    this.setState({
      [name]: value
    });
  };
  validateAdd = () => {
    const {
      // sourceSelected,
      // traitValue,
      // traitSelected,
      // determinationValue,
      // determinationSelected,
      traitName,
      determinationName,
      relationID
    } = this.state;
    /*
      cropSelected,
      traitName,
      determinationName,
      relationID
   */

    const validation =
      traitName !== '' && determinationName !== '' && relationID !== '';
    // traitValue !== '' &&
    // traitSelected !== '' &&
    // determinationValue !== '' &&
    // determinationSelected !== '' &&
    // sourceSelected !== '';
    // console.log(validation);
    // return true;
    return !validation;
  };
  handleAddResult = () => {
    const _this = this;
    const {
      // traitSelected,
      // determinationSelected,
      cropSelected,
      traitName,
      determinationName,

      relationID
    } = this.state;

    let action = 'I';
    if (this.props.mode === 'edit') {
      action = 'U';
    }

    let obj = {
      relationID,
      traitValue: traitName.trim(),
      determinationValue: determinationName.trim(),
      action
    };

    if (this.props.mode === 'edit') {
      obj = Object.assign(
        {
          id: _this.props.editData.id
        },
        obj
      );
    }

    // console.log(cropSelected, obj);
    this.props.onAppend({
      cropCode: cropSelected,
      data: [obj]
    });
    this.props.close('');
    this.setState({
      // determinationSelected: '',
      determinationValue: '',
      // sourceSelected: '',
      // traitSelected: '',
      traitValue: '',
      traitName: '',
      determinationName: ''
    });
  };

  handleAddStay = () => {
    const _this = this;
    const {
      // traitSelected,
      // determinationSelected,
      cropSelected,
      traitName,
      determinationName,

      relationID
    } = this.state;

    let action = 'I';
    if (this.props.mode === 'edit') {
      action = 'U';
    }

    let obj = {
      relationID,
      traitValue: traitName.trim(),
      determinationValue: determinationName.trim(),
      action
    };

    if (this.props.mode === 'edit') {
      obj = Object.assign(
        {
          id: _this.props.editData.traitDeterminationResultID
        },
        obj
      );
    }

    // console.log(cropSelected, obj);
    this.props.onAppend({
      cropCode: cropSelected,
      data: [obj]
    });

    this.setState({
      // relationID: 0,
      // determinationSelected: '',
      // determinationValue: '',
      // sourceSelected: '',
      // traitSelected: '',
      // traitValue: '',
      traitName: '',
      determinationName: ''
    });
  };

  showFieldsTraitTypeNotTrueUI = () => {
    const { sourceSelected, cropSelected, traitType, traitName } = this.state;
    const showFields = cropSelected !== '' && sourceSelected !== '';
    if (showFields && !traitType === true) {
      return (
        <div>
          <label htmlFor="determination">Trait Value</label>
          <input
            name="traitName"
            type="text"
            value={traitName}
            onChange={this.handleChange}
          />
        </div>
      );
    }
    return null;
  };

  render() {
    // console.log(this.props.editData);
    const {
      sourceSelected,
      cropSelected,
      traitSuggestions,
      traitValue,
      traitType,
      // determinationSuggestions,
      determinationValue,

      traitName,
      determinationName,
      traitValuesList

      // determinationID,
      // determinatioName
    } = this.state;

    const showFields = cropSelected !== '' && sourceSelected !== '';
    const traitInput = {
      placeholder: 'Select Trait',
      value: traitValue,
      onChange: this.onTraitChange
    };

    /*
    const determinationInput = {
      placeholder: 'Select Determination',
      value: determinationValue,
      onChange: this.onDeterminationChange
    };
    */

    const buttonName = this.props.mode === 'edit' ? 'Edit ' : 'Add ';

    const traitValueCheckTrue = showFields && !traitType === true;
    const traitValueCheck = showFields && traitType;

    return (
      <Wrapper>
        <div className="modalContent">
          <div className="modalTitle">
            <i className="demo-icon icon-plus-squared info" />
            <span>Trait Result</span>
            <i
              role="presentation"
              className="demo-icon icon-cancel close"
              onClick={() => this.props.close('')}
              title="Close"
            />
          </div>
          <div className="modelsubtitle">
            <label>Crop</label>{/*eslint-disable-line*/}

            {this.props.mode === 'edit' && (
              <input type="text" value={cropSelected} disabled />
            )}

            {this.props.mode !== 'edit' && (
              <select
                name="cropSelected"
                value={this.state.cropSelected}
                onChange={this.handleChange}
              >
                <option value="">Select</option>
                {this.state.cropList.map(crop => (
                  <option key={crop.cropCode} value={crop.cropCode}>
                    {crop.cropCode}
                  </option>
                ))}
              </select>
            )}
          </div>

          <div className="modalBody">
            {/*
            <div>
              <label>Source</label>
              <select
                name="sourceSelected"
                value={this.state.sourceSelected}
                onChange={this.handleChange}
              >
                <option value="">Select</option>
                {this.state.sourceList.map(source => (
                  <option key={source.sourceID} value={source.code}>
                    {source.sourceName}
                  </option>
                ))}
              </select>
            </div>
            */}

            {showFields && (
              <div>
                <label htmlFor="trait">Traits</label> {/*eslint-disable-line*/}
                {this.props.mode === 'edit' && (
                  <input type="text" value={traitValue} disabled />
                )}
                {this.props.mode !== 'edit' && (
                  <Autosuggest
                    suggestions={traitSuggestions}
                    onSuggestionsFetchRequested={this.traitFetchReq}
                    onSuggestionsClearRequested={this.traitClearReq}
                    getSuggestionValue={this.traitSuggestionValue}
                    renderSuggestion={this.traitSuggestion}
                    inputProps={traitInput}
                  />
                )}
              </div>
            )}

            {showFields && (
              <div>
                <label htmlFor="determination">Determination</label>{/*eslint-disable-line*/}
                <input type="text" value={determinationValue} disabled />
                {/*
                {this.props.mode === '12edit' && (
                  <input type="text" value={determinationValue} disabled />

                )}
                {this.props.mode !== '12edit' && (
                  <Autosuggest
                    suggestions={determinationSuggestions}
                    onSuggestionsFetchRequested={this.determinationFetchReq}
                    onSuggestionsClearRequested={this.determinationClearReq}
                    getSuggestionValue={this.determinationSuggestionValue}
                    renderSuggestion={this.determinationSuggestion}
                    inputProps={determinationInput}
                  />
                )}
                */}
              </div>
            )}

            {traitValueCheckTrue && (
              <div>
                <label htmlFor="determination">Trait Value</label>{/*eslint-disable-line*/}
                <input
                  name="traitName"
                  type="text"
                  value={traitName}
                  onChange={this.handleChange}
                />
              </div>
            )}

            {traitValueCheck && (
              <div>
                <label htmlFor="determination">Trait Value List</label>{/*eslint-disable-line*/}
                <select
                  name="traitName"
                  value={traitName}
                  onChange={this.handleChange}
                >
                  <option value="">Select</option>
                  {traitValuesList.map(val => {
                    const { traitValueCode, traitValueName } = val;
                    return (
                      <option key={traitValueCode} value={traitValueCode}>
                        {traitValueName}
                      </option>
                    );
                  })}
                </select>
              </div>
            )}

            {showFields && (
              <div>
                <label htmlFor="determination">Determination Value</label>{/*eslint-disable-line*/}
                <input
                  name="determinationName"
                  type="text"
                  value={determinationName}
                  onChange={this.handleChange}
                />
              </div>
            )}
          </div>

          <div className="modalFooter">
            {this.props.mode !== 'edit' && (
              <button
                disabled={this.validateAdd()}
                onClick={() => this.handleAddStay()}
              >
                {buttonName}
              </button>
            )}
            &nbsp;&nbsp;
            <button
              disabled={this.validateAdd()}
              onClick={this.handleAddResult}
            >
              {buttonName} &amp; Close
            </button>
          </div>
        </div>
      </Wrapper>
    );
  }
}

const mapState = state => ({
  crop: state.traitRelation.crop,
  trait: state.traitRelation.trait,
  determination: state.traitRelation.determination,
  relation: state.traitRelation.relation,
  traitValues: state.traitResult.traitValues
});
const mapDispatch = dispatch => ({
  fetchCrop: () => dispatch(fetchCrop()),
  fetchTrait: (traitName, cropCode, sourceSelected) =>
    dispatch(fetchTrait(traitName, cropCode, sourceSelected)),
  // fetchTraitValues: (cropCode, traitID) => {
  fetchTraitValues: cropTraitID => {
    // console.log('fetchTraitvalues', cropCode, traitID);
    // dispatch(getTraitValues(cropCode, traitID));
    dispatch(getTraitValues(cropTraitID));

    // console.info('crror fetch here', cropTraitID);
  },
  resetTraitValues: () => {
    // dispatch(traitValuesReset);
    // console.log(traitValuesReset);
    // console.log(traitValuesReset());
    dispatch(traitValuesReset());
  },
  fetchDetermination: (determinationName, cropCode) =>
    dispatch(fetchDetermination(determinationName, cropCode))
});

Result.defaultProps = {
  crop: [],
  trait: [],
  traitValues: [],
  // determination: [],
  editData: {},
  mode: ''
};
Result.propTypes = {
  crop: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  trait: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  // determination: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  traitValues: PropTypes.array, // eslint-disable-line react/forbid-prop-types

  close: PropTypes.func.isRequired,
  onAppend: PropTypes.func.isRequired,
  fetchCrop: PropTypes.func.isRequired,
  fetchDetermination: PropTypes.func.isRequired,
  fetchTrait: PropTypes.func.isRequired,
  fetchTraitValues: PropTypes.func.isRequired,
  resetTraitValues: PropTypes.func.isRequired,
  editData: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  mode: PropTypes.string
};

export default connect(
  mapState,
  mapDispatch
)(Result);
