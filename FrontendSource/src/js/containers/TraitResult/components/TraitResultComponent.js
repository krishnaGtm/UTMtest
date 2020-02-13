import React from 'react';
import PropTypes from 'prop-types';

import Result from './Result';
import List from './CheckList';
import { getDim } from '../../../helpers/helper';
import PHTable from '../../../components/PHTable';

class TraitResultComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,

      // sourceList: sources,
      sourceSelected: 'Phenome',

      resultList: props.result,

      // filter: [],
      // activeFilter: '',
      // visibility: false,
      checkVisibility: false,

      mode: '',
      editNode: {}
    };
  }
  componentDidMount() {
    const { pagenumber, pagesize, filter } = this.props;
    this.props.fetchData(pagenumber, pagesize, filter);
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
    // this.props.sidemenu();
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.result) {
      this.setState({
        resultList: nextProps.result
      });
      this.updateDimensions();
    }
    if (nextProps.checkList.length !== 0) {
      this.checkVisibility();
    }
  }
  componentWillUnmount() {
    window.removeEventListener('resize', this.updateDimensions);
  }

  onAddResult = obj => {
    const { pagesize, filter } = this.props;
    // console.log(obj);
    this.props.resultChanges(obj.cropCode, obj.data, 1, pagesize, filter);
  };

  onDeleteResult = (id, crop) => {
    const removeObj = {
      cropCode: crop,
      data: [{ id, action: 'D' }]
    };
    const confirmValue = confirm('Do you want to remove this Result mapping ?'); // eslint-disable-line
    if (confirmValue) {
      this.onAddResult(removeObj);
    }
  };

  onUpdateResult = id => {
    const editNode = this.state.resultList.find((result, i) => i === id);

    this.setState({
      editNode,
      mode: 'edit'
    });
  };

  filterFetch = () => {
    const { pagesize, filter } = this.props;
    this.props.fetchData(1, pagesize, filter);
  };

  filterClear = () => {
    this.props.filterClear();
    const { pagesize } = this.props;
    this.props.fetchData(1, pagesize, []);
  };

  pageClick = pg => {
    const { pagesize, filter } = this.props;
    this.props.fetchData(pg, pagesize, filter);
  };

  updateDimensions = () => {
    const dim = getDim();
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  };

  mode = mode => {
    this.setState({
      mode,
      editNode: mode === '' ? {} : this.state.editNode
    });
  };

  checkVisibility = (status = true) => {
    this.setState({
      checkVisibility: status
    });
    if (!status) {
      this.props.checkValidationClear();
    }
  };
  check = () => {
    this.props.checkValidation(this.state.sourceSelected);
    // this.checkVisibility();
  };

  filterClearUI = () => {
    const { filter: filterLength } = this.props;
    if (filterLength < 1) return null;
    return (
      <button className="with-i" onClick={this.filterClear}>
        <i className="icon icon-cancel" />
        Clear filters
      </button>
    );
  };

  formUI = () => {
    const { mode, editNode } = this.state;
    if (mode === '') return null;
    if (mode === 'add') {
      return (
        <Result
          close={this.mode}
          mode={mode}
          editData={editNode}
          onAppend={this.onAddResult}
        />
      );
    }
    return (
      <Result
        close={this.mode}
        mode={mode}
        editData={editNode}
        onAppend={this.onAddResult}
      />
    );
  };

  render() {
    const { tblHeight, tblWidth, checkVisibility } = this.state;
    const calcTblHeight = tblHeight - 125;
    /*
    const _this = this;
    tblWidth -= 30;
    if (this.props.sideMenu) {
      tblWidth -= 200;
    }
    const filterLength = this.props.filter.length;

    let tblHeaderHeight = 90;
    if (!visibility) {
      tblHeaderHeight = 40;
    }
    if (this.props.pagesize >= this.props.total) {
      if (this.props.filter.length === 0) {
        tblHeight += 45;
      }
    }
    */
    // if (this.props.total > 0) { tblHeight -= 20; }

    const columns = [
      'cropCode',
      'traitName',
      'traitValue',
      'determinationName',
      'determinationValue',
      'Action'
    ];
    const columnsMapping = {
      cropCode: { name: 'Crop', filter: true, fixed: true },
      traitName: { name: 'Trait', filter: true, fixed: true },
      traitValue: { name: 'Trait Value', filter: true, fixed: true },
      determinationName: { name: 'Determination', filter: true, fixed: true },
      determinationValue: { name: 'Value', filter: true, fixed: true },
      Action: { name: 'Action', filter: false, fixed: false }
    };
    const columnsWidth = {
      cropCode: 60,
      traitName: 160,
      traitValue: 160,
      determinationName: 160,
      determinationValue: 160,
      Action: 90
    };

    return (
      <div className="traitContainer">
        <section className="page-action">
          <div className="left"> {this.filterClearUI()} </div>
          <div className="right">
            <button className="with-i" onClick={() => this.check()}>
              <i className="icon icon-ok-circled" />
              Check
            </button>
            <button className="with-i" onClick={() => this.mode('add')}>
              <i className="icon icon-plus-squared" />
              Add Result
            </button>
          </div>
        </section>

        <div className="container">
          <PHTable
            sideMenu={this.props.sideMenu}
            filter={this.props.filter}
            tblWidth={tblWidth}
            tblHeight={calcTblHeight}
            columns={columns}
            data={this.props.result}
            pagenumber={this.props.pagenumber}
            pagesize={this.props.pagesize}
            total={this.props.total}
            pageChange={this.pageClick}
            filterFetch={this.filterFetch}
            filterClear={this.filterClear}
            columnsMapping={columnsMapping}
            columnsWidth={columnsWidth}
            filterAdd={this.props.filterAdd}
            actions={{
              name: 'result',
              add: () => {},
              edit: this.onUpdateResult,
              delete: this.onDeleteResult
            }}
          />
        </div>
        {this.formUI()}
        {checkVisibility && <List close={this.checkVisibility} />}
      </div>
    );
  }
}
TraitResultComponent.defaultProps = {
  checkList: [],
  result: [],
  total: 0,
  filter: []
};
TraitResultComponent.propTypes = {
  checkList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  result: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  total: PropTypes.number,
  pagenumber: PropTypes.number.isRequired,
  pagesize: PropTypes.number.isRequired,
  filter: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  fetchData: PropTypes.func.isRequired,
  sideMenu: PropTypes.bool.isRequired,
  filterAdd: PropTypes.func.isRequired,
  filterClear: PropTypes.func.isRequired,
  checkValidation: PropTypes.func.isRequired,
  checkValidationClear: PropTypes.func.isRequired,
  resultChanges: PropTypes.func.isRequired
};
export default TraitResultComponent;
