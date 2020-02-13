import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import moment from 'moment';
import DateInput from '../../../../../components/DateInput';
import ImportFile from './ImportFile';

class Breezys extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            testType: 'MT',
            todayDate: moment(),
            startDate: moment(),
            expectedDate: moment().add(14, 'days'),

            materialTypeID: '',
            materialStateID: '',
            containerTypeID: '',

            isolationStatus: false,
        };
    }
    handleChange = e => {
        const { target } = e;
        const {  name, value, type } = target;

        this.setState({
            [name]: type === "text"
            ? value : type === 'checkbox'
            ? target.checked : value * 1
            ? value * 1 : value
        });
        if (name === 'testType') {}
    };

    handlePlannedDateChange = date => {
        this.setState({
            startDate: date,
            expectedDate: moment(date).add(14, 'days')
        });
    };
    handleExpectedDateChange = date => {
        this.setState({ expectedDate: date });
    };

    render() {
        const {
            testType, todayDate, startDate, expectedDate,
            materialTypeID, materialStateID, containerTypeID,
            isolationStatus
        } = this.state;
        return (
            <Fragment>
                <div className="import-modal">
                    <div className="content">
                        <div className="title">
                            <span
                                className="close"
                                onClick={this.props.close}
                                tabIndex="0"
                                onKeyDown={() => {}}
                                role="button"
                            >
                                &times;
                            </span>
                            <span>Import Data from Breezys</span>
                        </div>
                        <div className="data-section">
                            <div className="body">
                                <div>
                                    <label>
                                        Test Type
                                        <select name="testType" value={this.state.testType} onChange={this.handleChange}>
                                            {this.props.testTypeList.map(x => (
                                                <option key={x.testTypeCode} value={x.testTypeCode}>
                                                    {x.testTypeName}
                                                </option>
                                            ))}
                                        </select>
                                    </label>
                                </div>

                                <DateInput label="Planned Week"todayDate={todayDate} selected={startDate} change={this.handlePlannedDateChange} />
                                <DateInput label="Expected Week"todayDate={startDate} selected={expectedDate} change={this.handleExpectedDateChange} />

                                <div>
                                    <label htmlFor="cropSelected">
                                        Material Type
                                        <select name="materialTypeID" value={this.state.materialTypeID} onChange={this.handleChange}>
                                            <option value="">Select</option>
                                            {this.props.materialTypeList.map(x => (
                                                <option key={x.materialTypeCode} value={x.materialTypeID}>
                                                    {x.materialTypeDescription}
                                                </option>
                                            ))}
                                        </select>
                                    </label>
                                </div>

                                <div>
                                    <label htmlFor="cropSelected">
                                        Material State
                                        <select name="materialStateID" value={this.state.materialStateID} onChange={this.handleChange}>
                                            <option value="">Select</option>
                                            {this.props.materialStateList.map(x => (
                                                <option key={x.materialStateCode} value={x.materialStateID}>
                                                    {x.materialStateDescription}
                                                </option>
                                            ))}
                                        </select>
                                    </label>
                                </div>

                                <div>
                                    <label htmlFor="cropSelected">
                                        Container Type
                                        <select name="containerTypeID" value={this.state.containerTypeID} onChange={this.handleChange}>
                                            <option value="">Select</option>
                                            {this.props.containerTypeList.map(x => (
                                                <option key={x.containerTypeCode} value={x.containerTypeID}>
                                                    {x.containerTypeName}
                                                </option>
                                            ))}
                                        </select>
                                    </label>
                                </div>

                                <div className="markContainer">
                                    <div className="marker">
                                        <input type="checkbox" name="isolationStatus" id="isolationModal" checked={this.state.isolationStatus} onChange={this.handleChange} />
                                        <label htmlFor="isolationModal">Already Isolated</label> {/*eslint-disable-line*/}
                                    </div>
                                </div>
                            </div>

                            <div className="footer">
                              <ImportFile
                                {...{
                                    testType,
                                    startDate,
                                    expectedDate,
                                    materialTypeID,
                                    materialStateID,
                                    containerTypeID,
                                    isolationStatus
                                }}
                                closeModal={this.props.close}
                                changeTabIndex={this.props.handleChangeTabIndex}
                                source={this.props.sourceSelected}
                              />
                            </div>
                        </div>
                    </div>
                </div>
            </Fragment>
        );
    }
}

export default Breezys;
