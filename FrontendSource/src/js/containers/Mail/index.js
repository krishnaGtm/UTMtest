import { connect } from 'react-redux';
import MailComponent from './components/MailComponent';
import { d_mailConfigFetch, d_mailConfigAppend, d_mailCconfigDestory } from './mailAction';

const mapState = state => ({
    sideMenu: state.sidemenuReducer,
    email: state.mailResult.data,
    total: state.mailResult.total.total,
    pagenumber: state.mailResult.total.pageNumber,
    pagesize: state.mailResult.total.pageSize,
    refresh: state.mailResult.total.refresh
});
const mapDispatch = dispatch => ({
    fetchMail: (pageNumber, pageSize) => dispatch(d_mailConfigFetch(pageNumber, pageSize)),
    addMailFunc: (configID, cropCode, configGroup, recipients) =>
    dispatch(d_mailConfigAppend(configID, cropCode, configGroup, recipients)),
    editMailFunc: (configID, cropCode, configGroup, recipients) =>
    dispatch(d_mailConfigAppend(configID, cropCode, configGroup, recipients)),
    deleteMailFunction: configID => dispatch(d_mailCconfigDestory(configID))
})
export default connect(
    mapState,
    mapDispatch
)(MailComponent);