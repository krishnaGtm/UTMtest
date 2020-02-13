import React from 'react';
import PropTypes from 'prop-types';
import PHTable from '../../components/PHTable';
import { getDim } from '../../helpers/helper';

class PlatPlanComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,
      relationList: props.relation,
      filter: props.filter,
      selectArray: []
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

  selectRow = (rowIndex, shift, ctrl) => {
    // remove it so selection of multiple row works
    return null;
    const { selectArray } = this.state;

      console.log('if selection true', rowIndex, shift, ctrl);
      if(ctrl) {
        console.log("ctrl");
        if (!selectArray.includes(rowIndex)) {
          this.setState({
            selectArray: [...selectArray, rowIndex]
          });
        }  else {
          const ind = selectArray.indexOf(rowIndex);
          const newSelect = [
            ...selectArray.slice(0, ind),
            ...selectArray.slice(ind + 1)
          ];
          if (newSelect.length === 0) {
            this.setState({ selectArray: [] });
          }
          this.setState({
            selectArray: newSelect
          });
        }
      } else if (shift) {
        console.log("shift");
        const newShiftArray = this.state.selectArray;
        newShiftArray.push(rowIndex);
        newShiftArray.sort((a, b) => a - b);
        const preArray = [];
        for (
          let i = newShiftArray[0];
          i <= newShiftArray[newShiftArray.length - 1];
          i += 1
        ) {
            preArray.push(i);
        }
        this.setState({selectArray: preArray });
      } else {
        console.log('Single click');
        const checkSelect = selectArray.includes(rowIndex);
        if (checkSelect) {
          this.setState({ selectArray: [] });
        } else {
          this.setState({ selectArray: [rowIndex] });
        }
      }
  };

  render() {
     const { tblWidth, tblHeight, filter: filterLength, selectArray } = this.state;

     const hasSelection = selectArray.length > 0;
     const hasFilter = filterLength.length > 0 || hasSelection;
     const subHeight = hasFilter ? 120 : 80;
     const calcHeight = tblHeight - subHeight;

     const columns = [
       'crop',
       'breedingStation',
       'test',
       'platePlan',
       'slotName',
       'plannedDate',
       'expectedDate',
       'status',
     ];
       // 'Action',
     const columnsMapping = {
       crop: { name: 'Crop', filter: true, fixed: false },
       breedingStation: { name: 'Br.Station', filter: true, fixed: true },
       test: { name: 'Test Name', filter: true, fixed: true },
       platePlan: { name: 'Plate Plan', filter: true, fixed: true },
       slotName: { name: 'Slot Name', filter: true, fixed: true },
       plannedDate: { name: 'Planned Date', filter: true, fixed: true },
       expectedDate: { name: 'Expected Date', filter: true, fixed: true },
       status: { name: 'Status', filter: true, fixed: true },
       Action: { name: 'Action', filter: false, fixed: false }
     };
     const columnsWidth = {
       crop: 80,
       breedingStation: 100,
       test: 180,
       platePlan: 160,
       slotName: 140,
       plannedDate: 130,
       expectedDate: 130,
       status: 200,
       Action: 81
     };

    return (
      <div className="traitContainer">
        {hasFilter && (
          <section className="page-action">
            <div className="left"> {this.filterClearUI()} </div>
            <div className="right">
              {hasSelection && false && <button>Printing</button>}
            </div>
          </section>
        )}
        <div className="container">
          <PHTable
            selection={true}
            selectArray={selectArray}
            selectRow={this.selectRow}

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
              name: 'planPlate',
              add: () => {},
              edit: () => {},
              delete: () => {}
            }}
          />
        </div>
      </div>
    );
  }
}
PlatPlanComponent.defaultProps = {
  relation: [],
  total: 0,
  filter: []
};
export default PlatPlanComponent;
