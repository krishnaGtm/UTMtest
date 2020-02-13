import {
  MAIL_CONFIG_FETCH,
  MAIL_CONFIG_APPEND,
  MAIL_CONFIG_UPDATE,
  MAIL_CONFIG_DESTORY
} from './mailConstant';

// SAGA
export const mailConfig_fetch = () => ({
  type: MAIL_CONFIG_FETCH
});

export const mailConfig_append = obj => ({
  type: MAIL_CONFIG_APPEND,
  ...obj
});

export const mailConfig_update = obj => ({
  type: MAIL_CONFIG_UPDATE,
  ...obj
});

export const mailConfig_delete = id => ({
  type: MAIL_CONFIG_DESTORY,
  id
});

// components
export const d_mailConfigFetch = (pageNumber, pageSize) => ({
  type: MAIL_CONFIG_FETCH,
  pageNumber, pageSize
});
export const d_mailConfigAppend = (configID, cropCode, configGroup, recipients) => ({
  type: MAIL_CONFIG_APPEND,
  configID, cropCode, configGroup, recipients
});
export const d_mailCconfigDestory = configID => ({
  type: MAIL_CONFIG_DESTORY,
  configID
});