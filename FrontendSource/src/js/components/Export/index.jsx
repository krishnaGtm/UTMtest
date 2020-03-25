import React, { Component } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

class Export extends Component {
  constructor(props) {
    super(props);
    this.state = {
      cropSelected: '',
      breedingStation: '',
      showall: false,
      exportList: [],
      exportFile: '',
      fileName: '',
      parent_cropSelected: props.cropSelected,
      parent_breedingStationSelected: props.breedingStationSelected
    };
  }

  componentDidMount() {
    if (this.props.cropSelected !== '') {
      this.setState({
        cropSelected: this.props.cropSelected
      });
    }
    if (this.props.breedingStationSelected !== '') {
      this.setState({
        breedingStation: this.props.breedingStationSelected
      });
    }
    if (this.props.cropSelected !== '' && this.props.breedingStationSelected !== '') {
      this.fetch(this.props.cropSelected, this.props.breedingStationSelected, this.state.showall);
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.exportList) {
      this.setState({
        exportList: nextProps.exportList
      });
    }
  }

  handleChange = ({ target }) => {
    const { cropSelected, breedingStation, showall } = this.state;
    const { type, name, value } = target;
    // console.log(type, name, value);
    const val = type === 'checkbox' ? target.checked : value;
    this.setState({
      [name]: val
    });

    const cropCondition = cropSelected !== '' && name === 'breedingStation';
    const breedCondition = breedingStation !== '' && name === 'cropSelected';
    const cropNbreedCondition =
      cropSelected !== '' &&
      breedingStation !== '' &&
      target.type === 'checkbox';
    if (name !== 'exportFile') {
      if (cropCondition) {
        this.fetch(cropSelected, value, showall);
      }
      if (breedCondition) {
        this.fetch(value, breedingStation, showall);
      }
      if (cropNbreedCondition) {
        this.fetch(cropSelected, breedingStation, val);
      }
    } else {
      this.setState({
        fileName: [name]
      });
    }
  };

  fetch = (cropCode, brStationCode, showAll) => {
    this.props.fetchExternalTests({
      cropCode,
      brStationCode,
      showAll
    });
  };

  downFile = mark => {
    const { exportFile: testID, fileName } = this.state;
    this.props.exportTest(testID, mark, fileName);
    this.props.close();
  };

  validate = () => this.state.exportFile === '';

  render() {
    const { cropSelected, breedingStation, showall, exportList, exportFile } = this.state;
    const { breedingStation: blist, crops } = this.props;
    return (
      <div className="slot-file-modal">
        <div className="slot-file-modal-content">
          <div className="slot-file-modal-title">
            <span
              onKeyDown={() => {}}
              className="slot-file-modal-close"
              onClick={this.props.close}
              tabIndex="0"
              role="button"
            >
              &times;
            </span>
            <span> Export to Excel</span>
          </div>
          <div className="slot-file-modal-body">
            <div className="marker">
              <input
                type="checkbox"
                id="showall"
                name="showall"
                onChange={this.handleChange}
                checked={showall}
              />
              <label htmlFor="showall">Show All</label>
            </div>
            <label htmlFor="cropSelected">
              Crops
              <select
                name="cropSelected"
                value={cropSelected}
                onChange={this.handleChange}
              >
                <option value="">Select</option>
                {crops.map(c => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </label>
            <label htmlFor="breedingStation">
              Br.Station
              <select
                name="breedingStation"
                value={breedingStation}
                onChange={this.handleChange}
              >
                <option value="">Select</option>
                {blist.map(b => (
                  <option
                    key={b.breedingStationCode}
                    value={b.breedingStationCode}
                  >
                    {b.breedingStationCode}
                  </option>
                ))}
              </select>
            </label>
            <br />
            <br />
            <label htmlFor="exportFile">
              Export File List
              <select
                name="exportFile"
                value={exportFile}
                onChange={this.handleChange}
              >
                <option value="">Select</option>
                {exportList.map(b => (
                  <option key={b.testID} value={b.testID}>
                    {b.testName}
                  </option>
                ))}
              </select>
            </label>
          </div>
          <div className="slot-file-modal-footer">
            {/* <button onClick={() => this.downFile(false)}> Export </button> */}
            &nbsp;
            <button
              onClick={() => this.downFile(true)}
              disabled={this.validate()}
            >
              Export
            </button>
          </div>
        </div>
      </div>
    );
  }
}
Export.defaultProps = {
  breedingStation: [],
  crops: [],
  exportList: []
};
Export.propTypes = {
  breedingStation: PropTypes.array, // eslint-disable-line
  crops: PropTypes.array, // eslint-disable-line
  exportList: PropTypes.array, // eslint-disable-line
  close: PropTypes.func.isRequired,
  exportTest: PropTypes.func.isRequired,
  fetchExternalTests: PropTypes.func.isRequired
};
const mapStateToProps = state => ({
  crops: state.user.crops,
  breedingStation: state.breedingStation.station,
  exportList: state.exportList,
  cropSelected: state.user.selectedCrop,
  breedingStationSelected: state.breedingStation.selected
});
const mapDispatchProps = dispatch => ({
  fetchExternalTests: obj => {
    dispatch({
      type: 'FETCH_EXTERNAL_TESTS',
      ...obj
    });
  },
  exportTest: (testID, mark, fileName) => {
    dispatch({
      type: 'EXPORT_EXTERNAL_TEST',
      testID,
      mark,
      fileName
    });
  }
});
export default connect(mapStateToProps, mapDispatchProps)(Export);
