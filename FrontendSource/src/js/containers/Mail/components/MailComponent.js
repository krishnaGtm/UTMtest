import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';


import Result from './Result';
// import List from './CheckList';
import { getDim } from '../../../helpers/helper';
import PHTable from '../../../components/PHTable';

import { MAIL_CONFIG_FETCH } from '../mailConstant';

// import AntdTable from '../../Test/AntdTable.jsx';

class MailComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tblWidth: 0,
      tblHeight: 0,
      data: props.email,
      total: props.total,
      pagesize: props.pagesize,
      pagenumber: props.pagenumber,
      refresh: props.refresh, // eslint-disable-line
      mode: '',
      editNode: {}
    };
  }

  componentDidMount() {
    window.addEventListener('resize', this.updateDimensions);
    this.updateDimensions();
    // this.props.sidemenu();
    this.props.fetchMail(this.props.pagenumber, this.props.pagesize);
  }
  componentWillReceiveProps(nextProps) {
    if (nextProps.refresh !== this.props.refresh) {
      this.setState({
        data: nextProps.email
      });
    }
    if (nextProps.total !== this.props.total) {
      this.setState({
        total: nextProps.total
      });
    }
    if (nextProps.pagenumber !== this.props.pagenumber) {
      this.setState({
        pagenumber: nextProps.pagenumber
      });
    }
  }
  componentWillUnmount() {
    window.removeEventListener('resize', this.updateDimensions);
  }

  onDeleteResult = id => {
    const { data } = this.state;

    const confirmValue = confirm('Do you want to remove this Mail Config?'); // eslint-disable-line
    if (confirmValue) {
      const { configID } = data[id];
      // this.onAddResult(removeObj);
      this.props.deleteMailFunction(configID);
    }
  };

  onUpdateResult = id => {
    const editNode = this.state.data.find((result, i) => i === id);
    this.setState({
      editNode,
      mode: 'edit'
    });
  };

  addEmail = ids => {
    const { cropCode, configGroup, recipients } = this.state.data[ids];
    // console.log('copyed row', cropCode, group);
    this.setState({
      mode: 'add',
      editNode: {
        configID: 0,
        cropCode,
        recipients: '',
        configGroup
      }
    });
  };


  filterFetch = () => {};
  filterClear = () => {};
  pageClick = pg => {
    // fetch date in new page
    this.props.fetchMail(pg, this.state.pagesize);

    // Highlight current page
    this.setState({pagenumber: pg });
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

  formUI = () => {
    const { mode, editNode, data } = this.state;
    if (mode === '') return null;
    const { crops } = this.props;

    // data , crops
    if (mode === 'add') {
      return (
        <Result
          close={this.mode}
          mode={mode}
          editData={editNode}
          onAppend={this.props.addMailFunc}
          crops={this.props.crops}
        />
      );
    }
    return (
      <Result
        close={this.mode}
        mode={mode}
        editData={editNode}
        onAppend={this.props.editMailFunc}
        crops={this.props.crops}
      />
    );
  };

  render() {
    const {
      tblHeight,
      tblWidth,
      data,
      total,
      pagesize,
      pagenumber
    } = this.state;
    const calcTblHeight = tblHeight - 125;

    const columns = [ 'configGroup', 'cropCode', 'recipients', 'Action'];
    const columnsMapping = {
      configGroup: { name: 'Group', filter: false, fixed: false },
      cropCode: { name: 'Crop Code', filter: false, fixed: false },
      recipients: { name: 'Recipients', filter: false, fixed: true },
      Action: { name: 'Action', filter: false, fixed: false }
    };
    const columnsWidth = {
      configGroup: 280,
      cropCode: 100,
      recipients: 300,
      Action: 100
    };

    // console.log(dataSource, columns);

    return (
      <div className="traitContainer">
        <section className="page-action">
          <div className="right">
            {/*<button className="with-i" onClick={() => this.mode('add')}>
              <i className="icon icon-plus-squared" />
              Add Result
            </button>*/}
          </div>
        </section>
        {/*style={{display:'none'}}*/}
        <div className="container">
          <PHTable
            sideMenu={this.props.sideMenu}
            filter={[]}
            tblWidth={tblWidth}
            tblHeight={calcTblHeight}
            columns={columns}
            data={data}
            pagenumber={pagenumber}
            pagesize={pagesize}
            total={total}
            pageChange={this.pageClick}
            filterFetch={this.filterFetch}
            filterClear={this.filterClear}
            columnsMapping={columnsMapping}
            columnsWidth={columnsWidth}
            filterAdd={() => {}}
            actions={{
              name: 'mail',
              add: this.addEmail,
              edit: this.onUpdateResult,
              delete: this.onDeleteResult
            }}
          />
        </div>
        {/*<div className="container">
          <AntdTable
            columns={columns}
            data={data}
          />
        </div>*/}
        {/*
        */}

        {this.formUI()}
      </div>
    );
  }
}

MailComponent.defaultProps = {
  email: [],
};
MailComponent.propTypes = {
  sideMenu: PropTypes.bool.isRequired,
  email: PropTypes.array, // eslint-disable-line react/forbid-prop-types
  total: PropTypes.number.isRequired,
  pagenumber: PropTypes.number.isRequired,
  pagesize: PropTypes.number.isRequired,
  refresh: PropTypes.bool.isRequired
};

const mapState = state => ({
  crops: state.user.crops
});
// const mapState = state => ({
//   email: state.mailResult.mail,
//   total: state.mailResult.total.total,
//   pagenumber: state.mailResult.total.pageNumber,
//   pagesize: state.mailResult.total.pageSize,
//   refresh: state.mailResult.total.refresh
// });

// export default Result;
export default connect(
  mapState,
  null
)(MailComponent);
// export default MailComponent;
