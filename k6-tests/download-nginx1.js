import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 2, // 2 virtual users
  duration: '2m', // 2分間実行
  rps: 10, // 秒間10リクエスト
};

export default function () {
  // nginx1経由でダウンロードテスト
  let response = http.get('http://localhost:8080/test/download/dummy-100kb');
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 1000ms': (r) => r.timings.duration < 1000,
    'content length is 100KB': (r) => r.body.length === 102400,
    'has proxy header': (r) => r.headers['X-Proxy-Pass'] === 'nginx1-data',
  });
  
  // レスポンス時間を記録
  console.log(`Download via nginx1: ${response.timings.duration}ms, Size: ${response.body.length} bytes`);
  
  sleep(0.1); // 100ms待機（10 RPS維持のため）
}