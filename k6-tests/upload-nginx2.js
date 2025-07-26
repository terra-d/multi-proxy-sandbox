import http from 'k6/http';
import { check, sleep } from 'k6';

// テスト用のファイルデータ（100KB）
const fileData = 'x'.repeat(102400);

export let options = {
  vus: 2, // 2 virtual users
  duration: '2m', // 2分間実行
  rps: 10, // 秒間10リクエスト
};

export default function () {
  // nginx2に直接アクセスでアップロードテスト
  let formData = {
    file: http.file(fileData, 'test-upload-100kb.bin', 'application/octet-stream'),
  };
  
  let response = http.post('http://localhost:8081/upload', formData);
  
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 2000ms': (r) => r.timings.duration < 2000,
    'has upload header': (r) => r.headers['X-Upload-Server'] === 'nginx2',
    'response contains success': (r) => r.body.includes('success'),
  });
  
  // レスポンス時間を記録
  console.log(`Upload direct nginx2: ${response.timings.duration}ms, Status: ${response.status}`);
  
  sleep(0.1); // 100ms待機（10 RPS維持のため）
}