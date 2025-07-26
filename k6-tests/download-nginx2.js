import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 2, // 2 virtual users
  duration: '1m', // 1分間実行
  rps: 10, // 秒間10リクエスト
};

export default function () {
  // nginx2に直接アクセスでダウンロードテスト
  let response = http.get('http://localhost:8081/files/dummy-100kb');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 1000ms': (r) => r.timings.duration < 1000,
    'content length is 100KB': (r) => r.body.length === 102400,
    'has server header': (r) => r.headers['X-Proxy-Pass'] === 'nginx2',
  });
  
  // レスポンス時間を記録
  console.log(`Download direct nginx2: ${response.timings.duration}ms, Size: ${response.body.length} bytes`);
  
  sleep(0.1); // 100ms待機（10 RPS維持のため）
}