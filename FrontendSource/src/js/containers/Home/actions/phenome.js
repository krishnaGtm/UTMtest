/**
 * Created by sushanta on 4/12/18.
 */
export const phenomeLogin = (token = '', user = '', pwd = '') =>  {
  // console.log(token, user, pwd);
  return {
    type: 'PHENOME_LOGIN',
    token,
    user,
    pwd
  };
};
// ({
//   type: 'PHENOME_LOGIN',
//   user,
//   pwd
// });
export const phenomeLoginDone = () => ({
  type: 'PHENOME_LOGIN_DONE'
});
export const getResearchGroups = () => ({
  type: 'GET_RESEARCH_GROUPS'
});
export const getResearchGroupsDone = data => ({
  type: 'GET_RESEARCH_GROUPS_DONE',
  data
});
export const getFolders = (id, path) => ({
  type: 'GET_FOLDERS',
  id,
  path
});
export const getFoldersDone = data => ({
  type: 'GET_FOLDERS_DONE',
  data
});
export const phenomeLogout = () => ({
  type: 'PHENOME_LOGOUT'
});
export const importPhenomeAction = data => ({
  type: 'IMPORT_PHENOME',
  data
});
