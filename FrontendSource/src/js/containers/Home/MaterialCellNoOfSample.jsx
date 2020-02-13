import React, { Component } from 'react';
import autoBind from 'auto-bind';
import { Cell } from 'fixed-data-table-2';
import { connect } from 'react-redux';

class MaterialCellNoOfSample extends Component {
  constructor(props) {
    super(props);
    this.state = {
      inputDisplay: !false,
      statusCode: props.statusCode,
      valueNumber: 0 //this.computevalue() // props.columnKey === 'NrOfSamples' ? 200 : 0
    };
    this.min = 1;
    this.max = 92 * 5;

    autoBind(this);
  }

  componentDidMount() {
    window.addEventListener('mousewheel', this.windowScroll, true)
  }

  windowScroll = e => {
    // console.log(e.target.type);
    // console.log('target', e.target.type === 'number');
    if(document.activeElement.type === "number" &&  document.activeElement.classList.contains("noscroll")) {
      document.activeElement.blur();
    }
    e.preventDefault();
    // window.blur();
    // return false;
  };

  sampleChange(e){
    const { rowIndex, data, sampleNumber } = this.props;
    const value = e.target.value;
    const { materialID } = sampleNumber[rowIndex];
    // console.log('value', value);
    if (value >= this.min && value <= this.max) {
      // console.log('true');
      this.props.sampleChange(materialID, value * 1);
      this.setState({
        valueNumber: value * 1
      });
    } else {
      // console.log('false');
      this.setState({
        valueNumber: 7 // this.computevalue()
      });
    }
  };

  /* computevalue = () => {
     const {
       rowIndex,
       columnKey,
       markerMaterialMap,
       data
     } = this.props;

     if(columnKey == 'NrOfSamples') {
       // const row = data[rowIndex]['nrOfSample'];
       console.log('NrOfSamples', this.props.sampleNumber[rowIndex]);
       const result = this.props.sampleNumber;
       // const dv = result.nrOfSample ? result.nrOfSample || 1;
       let dv = 11;
       if (result.length) {
         dv = result[rowIndex].nrOfSample;
         return dv;
       }
       return 0;
     } return 0;
   };*/

  componentWillReceiveProps(nextProps) {
    if (nextProps.statusCode !== this.props.statusCode) {
      this.setState({
        statusCode: nextProps.statusCode
      });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('mousewheel', this.windowScroll);
  }

  click = () => {
    this.setState({ inputDisplay: true });
  };

  inputFocus = e => {
    e.preventDefault();
    const { rowIndex } = this.props;
    this.props.indexChange(rowIndex);
    // console.log(123, ' - ', rowIndex);
  };

  render() {
    const {
      rowIndex,
      sampleNumber
    } = this.props;
    const { nrOfSample } = sampleNumber[rowIndex];

    const { inputDisplay, valueNumber } = this.state;

    // return (
    //   <Cell className="labCapacity">
    //     {nrOfSample}
    //     <input key={rowIndex} type="text" defaultValue={nrOfSample} onClick={this.click} readOnly={!inputDisplay} style={{width:'100px'}} />
    //   </Cell>
    //  );

    // const row = data[rowIndex];
    const dv = nrOfSample ? nrOfSample : 1;
    // let dv = 11;
    // if (result.length) {
    //   dv = result[rowIndex].nrOfSample;
    // }

    return (
      <Cell className="tableInputSampleNr">
        <input
          type="number"
          key={rowIndex}
          tabIndex={rowIndex + 1}

          value={nrOfSample}
          onChange={this.sampleChange}
          min={1}
          max={this.max}
          onFocus={this.inputFocus}
          className="noscroll"

          readOnly={this.state.statusCode >= 200}
        />
      </Cell>
    );
  }
}

const mapStateToProps = state => ({
  statusCode: state.rootTestID.statusCode,
  sampleNumber: state.assignMarker.numberOfSamples.samples,
  sampleRefresh: state.assignMarker.numberOfSamples.refresh,
});

const mapDispatchProps = dispatch => ({
  sampleChange: (materialID, nrOfSample) => {
    // console.log('sampleChange', materialID, nrOfSample);
    dispatch({
      type: 'SAMPLE_NUMBER_CHANGE',
      materialID,
      nrOfSample
    });
  }
})

export default connect(
  mapStateToProps,
  mapDispatchProps
  )(MaterialCellNoOfSample);
