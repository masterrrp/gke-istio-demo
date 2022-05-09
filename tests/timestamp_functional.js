import http from 'k6/http';
import { describe, expect } from 'https://jslib.k6.io/k6chaijs/4.3.4.1/index.js';

export const options = {
  thresholds: {
    checks: [{ threshold: 'rate == 1.00', abortOnFail: true }],
  },
};

export default function () {
  describe(`Testing timestamp app at http://${__ENV.TIMESTAMP_LB_IP}/`, () => {
    const response = http.get(`http://${__ENV.TIMESTAMP_LB_IP}/`);

    expect(response.status, 'response status').to.equal(200);
    expect(response).to.have.validJsonBody();
    expect(response.json(), 'timestamp response').to.include.keys('message', 'timestamp'); 
    expect(response.json(), 'timestamp response').to.be.an('object');
  });
}