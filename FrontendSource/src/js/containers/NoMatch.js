import React from 'react';

const style = {
  cont: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100%',
    padding: '30px 0 0'
  },
  title: {
    fontSize: '34px',
    fontWeight: 'normal',
    lineHeight: '42px',
    color: '#5a5a5a'
  },
  p: {
    fontSize: '20px',
    padding: '5px',
    color: '#5a5a5a'
  }
};

const NoMatch = () => (
  <div>
    <div className="container">
      <div style={style.cont}>
        <div
          style={{
            textAlign: 'center'
          }}
        >
          <p style={style.p}>
            You are not authorized to view this page.
          </p>
        </div>
      </div>
    </div>
  </div>
);
export default NoMatch;
