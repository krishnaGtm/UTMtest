/**
 * Created by sushanta on 4/12/18.
 */
import React from 'react';
import { decorators } from 'react-treebeard';

const modifiedDecorators = {
  ...decorators,
  Header: ({ node, style }) => {
    const imgBaseUrl =
      'https://onprem.unity.phenome-networks.com/static/images/icons/';
    return (
      <div
        style={{
          ...style.base,
          marginLeft: node.children === null ? '19px' : 0
        }}
      >
        <div style={style.title}>
          <span>
            <img
              alt="img icon"
              style={{ margin: '0 3px -3px 0' }}
              src={`${imgBaseUrl}${node.img}`}
            />
          </span>
          {node.name}
        </div>
      </div>
    );
  }
};

export default modifiedDecorators;
