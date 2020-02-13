import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import './move.scss';

class MoveForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedID: '',
      dataList: props.dataList
    };
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.dataList) {
      this.setState({
        dataList: nextProps.dataList
      });
    }
    if (nextProps.colList) {
      this.setState({
        colList: nextProps.colList
      });
    }
  }
  change = e => {
    this.setState({
      selectedID: e.target.value
    });
  };
  _close = () => {
    this.setState({
      selectedID: ''
    });
    this.props.close();
  };
  _onMove = (ids, selectedID, direction) => {
    this.props.onMove(ids, selectedID, direction);
    this.props.blockChange(true);
    // this.props.selected(1, false, true);
    this.props.selected(null, false, true, false);
    this.props.selectedArray(null);
    this.props.close();
  };
  render() {
    const { ids, moveShow } = this.props;
    const { dataList, colList, selectedID } = this.state;
    if (!moveShow) return null;

    let activeKey = '';
    colList.map(c => {
      if (c.materiallblColumn === 1) {
        // console.log(c.columnLabel);
        activeKey = c.columnLabel.toLowerCase();
      }
      return null;
    });

    return (
      <div className="moveWrap">
        <div className="moveContent">
          <div className="moveTitle ">
            <span>
              <i className="demo-icon icon-arrow-combo" />
              Move {selectedID}
            </span>
            <i className="demo-icon icon-cancel close" onClick={this._close} /> {/*eslint-disable-line*/}
          </div>
          <div className="moveBody">
            <select onChange={this.change}>
              <option value="">Select</option>
              {dataList.map((d, i) => {
                // console.log(d);
                if (d.fixed || ids.includes(i)) return null;
                // console.log(activeKey, d);
                return (
                  <option value={i} key={i}> {/*eslint-disable-line*/}
                    {d[activeKey]}
                  </option>
                );
              })}
            </select>
          </div>
          <div className="moveFooter">
            <button onClick={() => this._onMove(ids, selectedID, -1)}>
              Before
            </button>
            <button onClick={() => this._onMove(ids, selectedID, 1)}>
              After
            </button>
          </div>
        </div>
      </div>
    );
  }
}
MoveForm.propTypes = {
  ids: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  dataList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  close: PropTypes.func.isRequired,
  onMove: PropTypes.func.isRequired,
  blockChange: PropTypes.func.isRequired,
  selected: PropTypes.func.isRequired,
  selectedArray: PropTypes.func.isRequired,
  moveShow: PropTypes.bool.isRequired
};
const mapState = state => ({
  dataList: state.plateFilling.data,
  colList: state.plateFilling.column,
  statusCode: state.rootTestID.statusCode
});
const mapDispatch = dispatch => ({
  onMove: (moveIDs, selectedID, direction) => {
    if (selectedID === '') {
      alert('Select location'); // eslint-disable-line
    } else {
      dispatch({
        type: 'DATA_BIG_MOVE',
        moveIDs,
        id: selectedID,
        direction
      });
    }
  }
});

MoveForm.defaultProps = {
  colList: []
};
MoveForm.propTypes = {
  colList: PropTypes.array // eslint-disable-line react/forbid-prop-types
};

export default connect(mapState, mapDispatch)(MoveForm);
