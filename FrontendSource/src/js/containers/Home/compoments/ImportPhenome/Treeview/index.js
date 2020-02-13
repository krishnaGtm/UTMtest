/**
 * Created by sushanta on 4/12/18.
 */
import React from 'react';
import { connect } from 'react-redux';
import { Treebeard } from 'react-treebeard';
import { contains } from 'ramda';
import {
  getResearchGroups,
  getFolders,
  importPhenome
} from '../../../actions/phenome';
import modifiedDecorators from './modifiedDecorators';
import modifiedStyle from './modifiedStyle';
import './index.scss';

class Treeview extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }
  componentDidMount() {
    if (this.props.data.name === undefined) {
      this.props.getResearchGroups();
    }
  }
  onToggle = (n, toggled) => {
    const node = n;
    if (this.state.cursor) {
      this.setState({
        cursor: {
          ...this.state.cursor,
          active: false
        }
      });
    }
    node.active = true;
    if (node.children) {
      node.toggled = toggled;
    }
    this.setState({ cursor: node });
    if (contains(node.objectType, ['4', '5', '23']) && node.toggled) {
      // console.log('4, 5, 23');
      this.props.getFolders(node.id, node.path);
    }

    if (contains(node.objectType, ['24'])) {
      // console.log('24');
      this.folderID = {
        name: '',
        tree: null,
        folderObjectType: null,
        researchGroupObjectType: null
      };
      // console.log(node.id.split('~')[0]);
      const { objectType, id, researchGroupID } = node;
      // console.log(objectType, id, researchGroupID, '----');
      const { data } = this.props;
      const { children } = data;
      // console.log(children, id);
      this.findLevelID(children, 0, id);

      const { tree, folderObjectType, researchGroupObjectType } = this.folderID;

      const cropID = tree;

      // console.log('node', node);
      // console.log('this.folderID', this.folderID);
      // console.log(objectType, id, researchGroupID);
      // console.log('researchGroupObjectType', researchGroupObjectType);
      this.props.saveTreeObjectData(
        objectType,
        id,
        researchGroupID,

        cropID,
        folderObjectType,
        researchGroupObjectType
      );
      this.found = false;
    }
  };

  found = false;
  levelGroupObjectFound = false;
  folderID = {
    name: '',
    tree: null,
    folderObjectType: null,
    researchGroupObjectType: null
  };
  levelGroupObject = 1; // researchGroupObjectType
  levelCheck = 3; // tree
  findLevelID = (data, level, source) => {
    level++;
    // console.log(data, level, source);
    for (let i = 0; i < data.length; i += 1) {
      // console.log(data[i], ' 0000 ');
      if (this.found) break;
      const { id, children, name, objectType } = data[i];
      // console.log(data[i]);

      if (level === this.levelGroupObject && this.levelGroupObjectFound === false) {
        Object.assign(this.folderID, {
          researchGroupObjectType: '' // objectType
        });
      }
      if (level === this.levelCheck && this.found === false) {
        // console.log(id, name, objectType);
        Object.assign(this.folderID, {
          name,
          tree: id,
          folderObjectType: objectType
        });
      }
      if (source == id) {
        this.found = true;
        this.levelGroupObjectFound = true;
      }
      // console.log(children, level);
      if (children) {
        if (children.length > 0) {
          this.findLevelID(children, level, source);
        }
      }
    }
  };

  render() {
    const { data } = this.props;
    if (!data.name) {
      return null;
    }
    return (
      <div className="phenome-treeview">
        <Treebeard
          style={modifiedStyle}
          data={this.props.data}
          onToggle={this.onToggle}
          decorators={modifiedDecorators}
        />
      </div>
    );
  }
}

const mapStateToProps = state => ({
  isLoggedIn: state.phenome.isLoggedIn,
  data: state.phenome.treeData
});
const mapDispatchToProps = {
  getResearchGroups,
  getFolders
};

export default connect(mapStateToProps, mapDispatchToProps)(Treeview);
