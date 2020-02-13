import React from 'react';
import { connect } from 'react-redux';

class ImportFile extends React.Component {
    onSubmit = e => {
        e.preventDefault();
    };
    onChange = e => {
        this.fileValidation(e.target.files[0]);
    };

    fileValidation = xlsxFile => {
        const { pageSize, testType, testTypeList } = this.props;
        const fileName = xlsxFile.name;
        if (fileName) {
            let ext = fileName.slice(fileName.lastIndexOf('.') + 1);
            if (ext) {
                ext = ext.toLowerCase();
                if (ext !== 'xlsx') {
                    this.props.showError({
                        type: 'NOTIFICATION_SHOW',
                        status: true,
                        message: ['Please select ( *.XLSX ) file for import.'],
                        messageType: 2,
                        notificationType: 0,
                        code: ''
                    });
                    this.myFormRef.reset();
                } else {
                    const result = testTypeList.find(req => req.testTypeCode === testType);
                    const { testTypeID, determinationRequired } = result;
                    const {
                        materialTypeID, materialStateID, containerTypeID,
                        isolationStatus, startDate, expectedDate,
                        source
                    } = this.props;
                    // return;
                    const obj = {
                        pageSize,
                        pageNumber: 1,
                        file: xlsxFile,
                        testTypeID,
                        determinationRequired,
                        materialTypeID,
                        materialStateID,
                        containerTypeID,
                        isolated: isolationStatus,
                        date: startDate.format(userContext.dateFormat), // eslint-disable-line
                        expected: expectedDate.format(userContext.dateFormat), // eslint-disable-line
                        slotID: null,
                        source
                    };
                    // console.log(obj);
                    this.props.fileUpload(obj);
                    this.props.changeTabIndex(0);
                    // this.props.closeModal();
                    // this.myFormRef.reset();
                }
            }
        }
    };

    handleFileSelect = () => {
        const { materialTypeID, materialStateID, containerTypeID } = this.props;
        if (materialTypeID === 0 || materialStateID === 0 || containerTypeID === 0) {
            this.props.showError({
                type: 'NOTIFICATION_SHOW',
                status: true,
                message: [
                    'Please select Material Type, Material State and Container Type.'
                ],
                messageType: 2,
                notificationType: 0,
                code: ''
            });
        } else {
            this.uploadFileInput.click();
        }
    };

    render() {
        return (
            <div className="importFileWrap">
                <form onSubmit={this.onSubmit} ref={el => {this.myFormRef = el}}>
                    <input ref={el => {this.uploadFileInput = el}}
                        id="fileN"
                        type="file"
                        className="xlsFile"
                        onChange={this.onChange}
                    />
                    <button
                        type="button"
                        title="Import"
                        className="btnImportFile"
                        onClick={this.handleFileSelect}
                    >
                        Select a new file to import
                    </button>
                </form>
            </div>
        );
    }
}
const mapState = state => ({
    pageSize: state.assignMarker.total.pageSize,
    testTypeList: state.assignMarker.testType.list
});
const mapDispatch = dispatch => ({
    fileUpload: obj => {
        // console.log(obj);
        dispatch({ ...obj, type: 'UPLOAD_ACTION' });
        dispatch({ type: 'FILTER_CLEAR' });
        dispatch({ type: 'FILTER_PLATE_CLEAR' });
    },
    showError: obj => dispatch(obj)
});
export default connect(mapState, mapDispatch)(ImportFile);
