import React from 'react';
import autoBind from 'auto-bind';
import PropTypes from 'prop-types';

class PageLink extends React.Component {
  constructor(props) {
    super(props);
    autoBind(this);
  }

  finalClick() {
    this.props.click(this.props.page);
  }

  render() {
    const { active, page } = this.props;
    if (active) return <li className="active">{page}</li>;
    return (
      <li onClick={this.finalClick} className={active ? 'active' : ''}> {/* eslint-disable-line */}
        {page}
      </li>
    );
  }
}

PageLink.propTypes = {
  page: PropTypes.number.isRequired,
  click: PropTypes.func.isRequired,
  active: PropTypes.bool.isRequired
};

export default PageLink;
