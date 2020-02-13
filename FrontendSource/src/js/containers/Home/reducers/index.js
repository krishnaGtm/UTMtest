import { combineReducers } from 'redux';
import file from './filelistReducer';
import column from './column';
import data from './data';
import filter from './filter';
import total from './total';
import testType from '../compoments/TestType/testTypeReducer';
import marker from '../compoments/Marker/markerReducer';
import materials, { numberOfSamples } from './manageMarker';
import threegb from './threegb';
// import threeGBmark from './threeGBmark';

const assignMarker = combineReducers({
  file,
  column,
  data,
  filter,
  total,
  testType,
  marker,
  materials,
  threegb,
  numberOfSamples
});
// threeGBmark

export default assignMarker;
