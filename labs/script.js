
import http from 'k6/http';
import {check, sleep} from 'k6';
import {Rate} from 'k6/metrics';
import {parseHTML} from "k6/html";

const reqRate = new Rate('http_req_rate');

export const options = {
    stages: [
        {target: 20, duration: '20s'},
        {target: 20, duration: '20s'},
        {target: 0, duration: '20s'},
    ],
    thresholds: {
        'checks': ['rate>0.9'],
        'http_req_duration': ['p(95)<1000'],
        'http_req_rate{deployment:echo-v1}': ['rate>=0'],
        'http_req_rate{deployment:echo-v2}': ['rate>=0'],
    },
};

export default function () {
    const params = {
        headers: {
            'Host': 'canary.example.com',
            'Content-Type': 'text/plain',
        },
    };

    const res = http.get(`http://localhost/echo`, params);
    check(res, {
        'status code is 200': (r) => r.status === 200,
    });
   
  
    var body = res.body.replace(/[\r\n]/gm, '');

    switch (body) {
        case '"echo-v1"':
            reqRate.add(true, { deployment: 'echo-v1' });
            reqRate.add(false, { deployment: 'echo-v2' });
            break;
        case '"echo-v2"':
            reqRate.add(false, { deployment: 'echo-v1' });
            reqRate.add(true, { deployment: 'echo-v2' });
            break;
    }

    sleep(1);
}
