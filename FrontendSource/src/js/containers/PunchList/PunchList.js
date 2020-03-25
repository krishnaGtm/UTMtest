/**
 * Created by psindurakar on 1/8/2018.
 */
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';


import { sidemenuClose } from '../../action/index';
import RowDraw from './components/RowDraw';
import RowHead from './components/RowHead';
import Barcode from './components/Barcode';
import './punchlist.scss';

class PunchList extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: props.punchList
    };
    this.props.pageTitle();
  }
  componentDidMount() {
    // this.props.sidemenu();
    if (this.props.testID) {
      this.props.fetch_punchList(this.props.testID);
    } else {
      this.props.history.push('/');
    }
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.punchList !== this.props.punchList) {
      this.setState({ data: nextProps.punchList });
    }
  }
  render() {
    const data = this.state.data || [];
    return (
      <div className="container punchlist">
        <div className="trow">
          <div className="tcell">
            <div>
              {data.map(plate => {
                const {
                  plateID,
                  fileTitle,
                  platePlanName,
                  platePlanBarCode,
                  plateName,
                  barCode,
                  totalColumns,
                  rows,
                  slotName
                } = plate;
                return (
                  <div className="plateWrap" key={plateID}>
                    <div>
                      <div className="plateTitle">
                        <span className="fileTitle">{fileTitle}</span>
                        <span>{slotName}</span>
                      </div>
                      <div className="barcodeContainer">
                        <Barcode
                          legend="Plate Plan"
                          title={platePlanName}
                          barcode={platePlanBarCode}
                        />
                        <Barcode
                          legend="Plate"
                          title={plateName}
                          barcode={barCode}
                        />
                      </div>
                      <RowHead cols={totalColumns} />
                      {rows.map((row, rowIndex) => (
                        <div key={rowIndex}> {/*eslint-disable-line*/}
                          <RowDraw rows={row} cols={totalColumns} />
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapState = state => ({
  testID: state.rootTestID.testID,
  punchList: state.plateFilling.punchlist
});
const mapDispatch = dispatch => ({
  pageTitle: () => {
    dispatch({
      type: 'SET_PAGETITLE',
      title: 'Punch List'
    });
  },
  sidemenu: () => dispatch(sidemenuClose()),
  fetch_punchList: testID => {
    dispatch({
      type: 'FETCH_PUNCHLIST',
      testID
    });
  }
});
PunchList.defaultProps = {
  testID: 0
};
PunchList.propTypes = {
  fetch_punchList: PropTypes.func.isRequired,
  pageTitle: PropTypes.func.isRequired,
  sidemenu: PropTypes.func.isRequired,
  testID: PropTypes.number,
  punchList: PropTypes.array.isRequired // eslint-disable-line react/forbid-prop-types
};

export default connect(mapState, mapDispatch)(PunchList);
