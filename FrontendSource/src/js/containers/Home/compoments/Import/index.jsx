import React from 'react';
import { connect } from 'react-redux';

import Wrapper from '../../../../components/Wrapper/wrapper.jsx';

import Phenome from './Phenome';
import Breezys from './Breezys';
import External from './External';

class Import extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            sourceSelected: props.sourceSelected,
            existFile: props.existFile,
        };
        // console.log('props', props);
    }

    componentWillReceiveProps(nextProps) {
        if (this.props.sourceSelected !== nextProps.sourceSelected) {
            this.setState({ sourceSelected: nextProps.sourceSelected });
        }
    }

    import = () => {
        console.log('import function');
    };

    render() {
        const { sourceSelected } = this.state;
        if (sourceSelected === "Breezys") {
            return <Breezys {...this.state} {...this.props} />
        }
        if (sourceSelected === "Phenome") {
            return <Phenome {...this.state} {...this.props} />
        }
        return <External {...this.state} {...this.props} />;
        return null;
    }
}

const mapState = state => ({
    testTypeList: state.assignMarker.testType.list,
    materialTypeList: state.materialType,
    materialStateList: state.materialState,
    containerTypeList: state.containerType,
    warningFlag: state.phenome.warningFlag,
    warningMessage: state.phenome.warningMessage
});

export default connect(mapState, null)(Import);
