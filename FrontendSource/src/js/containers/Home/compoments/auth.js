import { AuthenticationContext } from 'react-adal';

export const adalConfig = {
  instance: window.sso.instance,
  tenant: window.sso.tenant,
  clientId: window.sso.clientId,
  cacheLocation: window.sso.cacheLocation,
  redirectUri: window.sso.redirectUri,
  popUp: true
};

export const authContext = x => new AuthenticationContext(x);

export const getToken = s => {
  return s.getCachedToken(authContext.config.clientId);
};
