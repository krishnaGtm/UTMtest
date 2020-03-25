import axios from 'axios';

function utmLogin() {
  // alert(123);
  return axios({
    method: 'post',
    url: 'https://onprem.unity.phenome-networks.com/login_do',
    data: {
      username: 'user@enzazaden.com',
      password: 'enzds321'
    }
  });
}
export default utmLogin;
