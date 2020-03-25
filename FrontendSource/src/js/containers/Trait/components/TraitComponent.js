import React from 'react';
import PropTypes from 'prop-types';
import Relation from './Relation';
import PHTable from '../../../components/PHTable';
import { getDim } from '../../../helpers/helper';

class TraitComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,
      relationList: props.relation,
      filter: props.filter,
      mode: '',
      editNode: {}
    };
  }

  componentDidMount() {
    const { pagenumber, pagesize, filter } = this.props;
    this.props.fetchDate(pagenumber, pagesize, filter);
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.relation) {
      this.setState({
        relationList: nextProps.relation
      });
      this.updateDimensions();
    }
    if (nextProps.filter.length !== this.props.filter) {
      this.setState({
        filter: nextProps.filter
      });
    }
  }
  componentWillUnmount() {
    window.removeEventListener('resize', this.updateDimensions);
  }

  onAddRelation = obj => {
    const { pagenumber, pagesize, total, filter } = this.props;

    const newObj = {
      relationTraitDetermination: [obj],
      filter,
      pageNumber: pagenumber,
      pageSize: pagesize,
      totalRows: total
    };
    this.props.relationChanges(newObj);
  };

  onDeleteRelation = id => {
    // const { filter } = this.state;
    const { pagenumber, pagesize, total, filter } = this.props;

    const removeObj = {
      relationTraitDetermination: [
        {
          relationID: id,
          action: 'D'
        }
      ],
      filter,
      pageNumber: pagenumber,
      pageSize: pagesize,
      totalRows: total
    };
    // console.log('onDeleteRelation', removeObj);
    const confirmValue = confirm('Do you want to remove Trait - Determination relation ?'); // eslint-disable-line
    if (confirmValue) {
      this.props.relationChanges(removeObj);
    }
  };

  onUpdateRelation = id => {
    this.mode('edit');
    this.setState({
      editNode: this.state.relationList.find(
        relation => relation.traitID === id
      )
    });
  };

  updateDimensions = () => {
    const dim = getDim();
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  };

  filterFetch = () => {
    // console.log('filter fetch index page');
    const { pagesize, filter } = this.props;
    this.props.fetchDate(1, pagesize, filter);
  };

  filterClear = () => {
    const { pagesize } = this.props;
    this.props.filterClear();
    this.props.fetchDate(1, pagesize, []);
  };

  pageClick = pg => {
    const { pagesize, filter } = this.props;
    this.props.fetchDate(pg, pagesize, filter);
  };

  mode = mode => {
    this.setState({
      mode,
      editNode: mode === '' ? {} : this.state.editNode
    });
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
        <Relation close={this.mode} mode={mode} onAppend={this.onAddRelation} />
      );
    }
    return (
      <Relation
        close={this.mode}
        mode={mode}
        editData={editNode}
        onAppend={this.onAddRelation}
      />
    );
  };

  render() {
    const { tblWidth, tblHeight, filter: filterLength } = this.state;

    const hasFilter = filterLength.length > 0;
    const subHeight = hasFilter ? 120 : 70;
    const calcHeight = tblHeight - subHeight;

    const columns = [
      'cropCode',
      'traitLabel',
      'determinationName',
      'status',
      'Action'
    ];
    const columnsMapping = {
      cropCode: { name: 'Crop', filter: true, fixed: false },
      traitLabel: { name: 'Trait', filter: true, fixed: true },
      determinationName: { name: 'Determination', filter: true, fixed: true },
      status: { name: 'Status', filter: true, fixed: true },
      Action: { name: 'Action', filter: false, fixed: false }
    };
    const columnsWidth = {
      cropCode: 100,
      traitLabel: 160,
      determinationName: 160,
      status: 160,
      Action: 80
    };

    return (
      <div className="traitContainer">
        {hasFilter && (
          <section className="page-action">
            <div className="left"> {this.filterClearUI()} </div>
            <div className="right" />
          </section>
        )}

        <div className="container">
          <PHTable
            sideMenu={this.props.sideMenu}
            filter={this.props.filter}
            tblWidth={tblWidth}
            tblHeight={calcHeight}
            columns={columns}
            data={this.props.relation}
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
              name: 'relation',
              add: this.onAddRelation,
              edit: this.onUpdateRelation,
              delete: this.onDeleteRelation
            }}
          />
        </div>
        {this.formUI()}
      </div>
    );
  }
}
TraitComponent.defaultProps = {
  relation: [],
  total: 0,
  filter: []
};
TraitComponent.propTypes = {
  relation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  total: PropTypes.number,
  pagenumber: PropTypes.number.isRequired,
  pagesize: PropTypes.number.isRequired,
  filter: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  relationChanges: PropTypes.func.isRequired,
  fetchDate: PropTypes.func.isRequired,
  filterClear: PropTypes.func.isRequired,
  filterAdd: PropTypes.func.isRequired,
  sideMenu: PropTypes.bool.isRequired
};
export default TraitComponent;
