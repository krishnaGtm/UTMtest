/**
 * type
 * ===========================
 * 0: error,
 * 1: info,
 * 2: success
 *
 * messageType
 * =============================
 * 1: default message,
 *  2: system message
 */
const init = {
  code: '',
  commonMessage: '',
  message: [],
  messageType: null,
  notificationType: null,
  status: false
};
const commonMessage = ['Please contact your administrator'];

const notify = (state = init, action) => {
  switch (action.type) {
    case 'NOTIFICATION_SHOW':
      return {
        code: action.code,
        commonMessage,
        message: action.message,
        messageType: action.messageType,
        notificationType: action.notificationType,
        status: true
      };
    case 'NOTIFICATION_HIDE':
      return init;
    default:
      return state;
  }
};
export default notify;
