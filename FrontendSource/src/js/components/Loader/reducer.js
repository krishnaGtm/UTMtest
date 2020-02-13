/**
 * Created by psindurakar on 12/26/2017.
 */

const loader = (state = 0, action) => {
  // return 0;
  let source = '';
  if (action.func)
    source = action.func;
  else
    source = "undefine";

  switch (action.type) {
    case 'LOADER_RESET':
      return 0;
    case 'LOADER_SHOW':
      /*if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
        console.log(source, state, '++');
      }*/
      return state + 1;
    case 'LOADER_HIDE':
      /*if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
        console.log(source, state, '--');
      }*/
      if (state > 0)
        return state - 1;
      // return state;
    default:
      return state;
  }
};
export default loader;

