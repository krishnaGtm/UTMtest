// routes
import Home from './containers/Home/Home';
import PlateFilling from './containers/PlateFilling/PlateFilling';

import PlatPlan from './containers/PlatPlan';

import Breeder from './containers/Breeder';
// import BreederOverview from './containers/BreederOverview/index';

import Lab from './containers/Lab';
import LabOverview from './containers/LabOverview';
import LabApproval from './containers/LabApproval';

import PrintList from './containers/PunchList/PunchList';
import Trait from './containers/Trait';
import TraitResult from './containers/TraitResult';

import Mail from './containers/Mail/index';

export const routeList = [
  { name: 'Assign marker', to: '/', role: 'utmCommonRole', comp: Home},
  { name: 'Plate filling', to: '/platefilling', role: 'utmCommonRole', comp: PlateFilling},

  // { name: '', to: '/punchlist', role: 'utmCommonRole', comp: PrintList},
  // { name: '', to: '/samplelist', role: 'utmCommonRole', comp: PrintList},

  { name: 'PlatePlan Overview', to: '/platplan', role: 'platePlansRole', comp: PlatPlan },
  { name: 'Capacity Planning', to: '/breeder', role: 'requesttest', comp: Breeder},
  // { name: 'Breader Overview', to: '/breeder-overview', role: 'requesttest', comp: BreederOverview},


  { name: 'Traits Relation', to: '/traits', role: 'managemasterdatautm', comp: Trait},
  { name: 'Traits Result', to: '/result-traits', role: 'managemasterdatautm', comp: TraitResult},

  { name: 'Lab Capacity', to: '/lab', role: 'handlelabcapacity', comp: Lab },
  { name: 'Lab Overview', to: '/lab-overview', role: 'handlelabcapacity', comp: LabOverview },
  { name: 'Lab Approval', to: '/lab-approval', role: 'handlelabcapacity', comp: LabApproval },

  { name: 'Mail Config', to: '/mail', role: 'admin', comp: Mail},
];

export const couputeRoute = (role, testTypeID) => {

  const requestTestRole = role.includes('requesttest');
  const manageMasterDataUTMRole = role.includes('managemasterdatautm');
  const handleLabCpapacityRole = role.includes('handlelabcapacity');
  const adminRole = role.includes('admin');
  const platePlansRole = requestTestRole || handleLabCpapacityRole;
  const utmCommonRole = requestTestRole || manageMasterDataUTMRole || adminRole;

  const accessRoute = [];
  routeList.map(x => {
    const { name, to, role: rr } = x;
    switch (rr) {
      case 'utmCommonRole': {
        if (utmCommonRole) {
          if (name === "Plate filling") {
            // TODO :: improve this code
            // console.log('testTypeID', testTypeID);
            if (testTypeID < 4 || testTypeID > 5) {
              accessRoute.push(x);
            }
          } else {
            accessRoute.push(x);
          }
        }
        break;
      }
      case 'platePlansRole':
        if (platePlansRole)
          accessRoute.push(x);
        break;
      default: {
        if (role.includes(rr))
          accessRoute.push(x);
      }
    }
  });
  // console.log(accessRoute, role);
  return accessRoute;
}
