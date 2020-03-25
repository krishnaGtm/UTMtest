import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

class ImportFileComponent extends React.Component {
    onFormSubmit = e => {
        e.preventDefault(); // Stop form submit
    };

    onChange = e => {
        this.fileValidation(e.target.files[0]);
    };

    fileValidation = xlsxFile => {
        const { pageSize, testTypeID, testTypeList } = this.props;
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
                    const result = testTypeList.find(req => req.testTypeID === parseInt(testTypeID, 10));
                    const obj = {
                        pageSize,
                        pageNumber: 1,
                        file: xlsxFile,
                        testTypeID,
                        determinationRequired: result.determinationRequired,
                        materialTypeID: this.props.materialTypeID,
                        materialStateID: this.props.materialStateID,
                        containerTypeID: this.props.containerTypeID,
                        isolated: this.props.isolationStatus,
                        date: this.props.selectedDate.format(userContext.dateFormat), // eslint-disable-line
                        expected: this.props.expectedDate.format(userContext.dateFormat), // eslint-disable-line
                        slotID: null,
                        source: 'Breezys'
                    };
                    this.props.fileUpload(obj);
                    this.props.changeTabIndex(0);
                    this.props.closeModal();
                    this.myFormRef.reset();
                }
            }
        }
    };

    handleFileSelect = () => {
        if (
            this.props.materialTypeID === 0 ||
            this.props.materialStateID === 0 ||
            this.props.containerTypeID === 0
        ) {
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
                <form
                    onSubmit={this.onFormSubmit}
                    ref={el => {
                        this.myFormRef = el;
                    }}
                >
                    <input
                        ref={el => {
                            this.uploadFileInput = el;
                        }}
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

// container component
const mapStateToProps = state => ({
    pageSize: state.assignMarker.total.pageSize,
    testTypeList: state.assignMarker.testType.list
});
const mapDispatchToProps = dispatch => ({
    fileUpload: obj => {
        // console.log(obj);
        dispatch({ ...obj, type: 'UPLOAD_ACTION' });
        dispatch({ type: 'FILTER_CLEAR' });
        dispatch({ type: 'FILTER_PLATE_CLEAR' });
    },
    showError: obj => {
        dispatch(obj);
    }
});

// ImportFile.defaultProps = {}
ImportFileComponent.propTypes = {
    pageSize: PropTypes.number.isRequired,
    testTypeID: PropTypes.number.isRequired,
    materialTypeID: PropTypes.number.isRequired,
    materialStateID: PropTypes.number.isRequired,
    containerTypeID: PropTypes.number.isRequired,
    selectedDate: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
    expectedDate: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
    isolationStatus: PropTypes.bool.isRequired,
    testTypeList: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
    showError: PropTypes.func.isRequired,
    fileUpload: PropTypes.func.isRequired,
    closeModal: PropTypes.func.isRequired,
    changeTabIndex: PropTypes.func.isRequired
};
const ImportFile = connect(mapStateToProps, mapDispatchToProps)(ImportFileComponent);
export default ImportFile;
