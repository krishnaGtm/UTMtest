export function checkStatus(status, type = '') {
  switch (type) {
    case 'CREATED':
      return status === 100;
    case 'REQUESTED':
      return status === 200;
    case 'RESERVED':
      return status === 300;
    case 'CONFIRM':
      return status === 400;
    case 'INLIMS':
      return status === 500;
    case 'RECEIVED':
      return status === 600;
    case 'COMPLETED':
      return status === 700;
    default:
      return false;
  }
}
export function getDim() {
  const width = window.document.body.offsetWidth;
  const height = window.document.body.offsetHeight;
  return {
    width,
    height
  };
}
export function getStatusName(status, array) {
  // console.log(Array.isArray(array));
  if (array) {
    const match = array.find(d => d.statusCode === status);
    if (match) return `- ${match.statusName}`;
  }
  return '';
}

const flag = !true;
export const show = func => flag ? ({ type: 'AAAA' }) : ({ type: 'LOADER_SHOW', func });
export const hide = func => flag ? ({ type: 'AAAA' }) : ({ type: 'LOADER_HIDE', func });
