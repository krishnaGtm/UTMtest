import React from 'react';
import PropTypes from 'prop-types';
import PHTable from '../../../components/PHTable/';
import { getDim } from '../../../helpers/helper';

class BreederOverviewComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,
      list: props.slotList,
      // filter: [],
      // activeFilter: '',
      // visibility: false,
      pagenumber: props.pagenumber,
      pagesize: props.pagesize,
      total: props.total,

      cropSelected: props.cropSelected,
      breedingStation: props.breedingStation,
      breedingStationSelected: props.breedingStationSelected
    };
  }
  componentDidMount() {
    window.addEventListener('beforeunload', this.handleWindowClose);
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
    // this.props.sidemenu();

    const { cropSelected, breedingStationSelected } = this.props;
    if (cropSelected !== '' && breedingStationSelected !== '') {
      this.slotCall(cropSelected, breedingStationSelected);
    } else {
      this.props.fetchBreeding();
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.cropSelected !== this.props.cropSelected) {
      this.setState({ cropSelected: nextProps.cropSelected });
      if (nextProps.breedingStationSelected !== '') {
        this.slotCall(nextProps.cropSelected, nextProps.breedingStationSelected);
      }
    }
    if (nextProps.breedingStation.length !== this.props.breedingStation.length) {
      this.setState({ breedingStation: nextProps.breedingStation });
    }
    if (nextProps.breedingStationSelected !== this.props.breedingStationSelected) {
      this.setState({
        breedingStationSelected: nextProps.breedingStationSelected
      });
      if (nextProps.cropSelected !== '') {
        // console.log(nextProps.cropSelected, nextProps.breedingStationSelected);
        this.slotCall(nextProps.cropSelected, nextProps.breedingStationSelected);
      }
    }

    if (nextProps.slotList !== this.props.slotList) {
      this.setState({
        list: nextProps.slotList
      });
    }

    if (nextProps.pagenumber !== this.props.pagenumber) {
      this.setState({
        pagenumber: nextProps.pagenumber
      });
    }
    if (nextProps.pagesize !== this.props.pagesize) {
      this.setState({
        pagesize: nextProps.pagesize
      });
    }
    if (nextProps.total !== this.props.total) {
      this.setState({
        total: nextProps.total
      });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('beforeunload', this.handleWindowClose);
    window.removeEventListener('resize', this.updateDimensions);
    this.props.breederSlotPageReset();
  }

  slotCall(cropCode, brStationCode) {
    const { pagenumber, pagesize, filter } = this.props;
    // console.log('slot ccall', cropCode, brStationCode);
    this.props.fetchSlot(cropCode, brStationCode, pagenumber, pagesize, filter);
  }

  updateDimensions = () => {
    const dim = getDim();
    // console.log(dim);
    this.setState({
      tblWidth: dim.width,
      tblHeight: dim.height
    });
  };

  /*
  filterVisible = filter => {
    this.setState({
      activeFilter: filter,
      visibility: !this.state.visibility
    });
  };
  */
  filterFetch = () => {
    const { cropSelected, breedingStationSelected } = this.state;
    const { pagesize, filter } = this.props;
    this.props.fetchSlot(cropSelected, breedingStationSelected, 1, pagesize, filter);
  };
  filterClear = () => {
    const { cropSelected, breedingStationSelected } = this.state;
    const { pagesize } = this.props;
    this.props.filterClear();
    this.props.fetchSlot(cropSelected, breedingStationSelected, 1, pagesize, []);
  };
  pageClick = pg => {
    const { cropSelected, breedingStationSelected } = this.state;
    const { pagesize, filter } = this.props;
    this.props.fetchSlot(cropSelected, breedingStationSelected, pg, pagesize, filter);
  };

  cropSelectFn = e => {
    const { value } = e.target;
    if (value !== '') {
      // this.props.emptyRowColumns();
      this.props.cropSelect(value);
    }
  };

  breedingStationSelectionFn = e => {
    const { value } = e.target;
    if (value !== '') {
      // console.log(value);
      // this.props.emptyRowColumns();
      this.props.breedingStationSelect(value);
    }
  };

  render() {
    let { tblHeight } = this.state;
    const { tblWidth, list } = this.state;
    const { pagenumber, pagesize, total } = this.state;

    tblHeight -= 95;

    const columns = [
      'cropCode',
      'breedingStationCode',
      'slotName',
      'periodName',
      'materialStateCode',
      'materialTypeCode',
      'totalPlates',
      'totalTests',
      'availablePlates',
      'availableTests',
      'statusName'
    ];
    const columnsMapping = {
      cropCode: { name: 'Crop', filter: true },
      breedingStationCode: { name: 'Br.Station', filter: true },
      slotName: { name: 'Slot Name', filter: true },
      periodName: { name: 'Period Name', filter: true },
      materialStateCode: { name: 'Material State', filter: true },
      materialTypeCode: { name: 'Material Type', filter: true },
      totalPlates: { name: 'Total Plates', filter: true },
      totalTests: { name: 'Total Tests', filter: true },
      availablePlates: { name: 'Available Plates', filter: true },
      availableTests: { name: 'Available Tests', filter: true },
      statusName: { name: 'Status', filter: true }
    };
    const columnsWidth = {
      cropCode: 80,
      breedingStationCode: 100,
      slotName: 160,
      periodName: 240,
      materialStateCode: 120,
      materialTypeCode: 120,
      availablePlates: 140,
      availableTests: 130,
      totalPlates: 120,
      totalTests: 120,
      statusName: 120
    };

    return (
      <div className="slotBreeder">
        <section className="page-action">
          <div className="left">
            <div className="form-e">
              <label htmlFor="year">Crop</label>
              <select
                name="corps"
                id="crops"
                value={this.state.cropSelected}
                onChange={this.cropSelectFn}
              >
                <option value="">Select</option>
                {this.props.crops.map(crop => (
                  <option value={crop} key={crop}>
                    {crop}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-e">
              <label>Br.Station</label>
              <select
                onChange={this.breedingStationSelectionFn}
                value={this.state.breedingStationSelected}
              >
                <option value="">Select</option>
                {this.state.breedingStation.map(breed => {
                  const { breedingStationCode } = breed;
                  return (
                    <option
                      key={breedingStationCode}
                      value={breedingStationCode}
                    >
                      {breedingStationCode}
                    </option>
                  );
                })}
              </select>
            </div>
          </div>
        </section>

        <div className="container">
          <PHTable
            fileSource
            sideMenu={this.props.sideMenu}
            filter={this.props.filter}
            tblWidth={tblWidth}
            tblHeight={tblHeight}
            columns={columns}
            data={list}
            pagenumber={pagenumber}
            pagesize={pagesize}
            total={total}
            pageChange={this.pageClick}
            filterFetch={this.filterFetch}
            filterClear={this.filterClear}
            columnsMapping={columnsMapping}
            columnsWidth={columnsWidth}
            filterAdd={this.props.filterAdd}
          />
        </div>
      </div>
    );
  }
}

BreederOverviewComponent.defaultProps = {
  slotList: [],
  filter: [],
  cropSelected: '',
  breedingStation: [],
  crops: [],
  breedingStationSelected: ''
};
BreederOverviewComponent.propTypes = {
  cropSelected: PropTypes.string,
  breedingStation: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  crops: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  breedingStationSelected: PropTypes.string,
  slotList: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  filter: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  pagenumber: PropTypes.number.isRequired,
  pagesize: PropTypes.number.isRequired,
  total: PropTypes.number.isRequired,
  fetchSlot: PropTypes.func.isRequired,
  filterClear: PropTypes.func.isRequired,
  filterAdd: PropTypes.func.isRequired,
  sideMenu: PropTypes.bool.isRequired,
  cropSelect: PropTypes.func.isRequired,
  breedingStationSelect: PropTypes.func.isRequired,
  fetchBreeding: PropTypes.func.isRequired
};
export default BreederOverviewComponent;
