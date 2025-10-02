import uWS from 'uWebSockets.js';

const app = uWS.App({});

// Tạo WebSocket server tại /ws
app.ws('/ws', {
  // Khi client kết nối
  open: (ws) => {
    console.log('Client connected');
    ws.subscribe('broadcast'); // Tham gia kênh broadcast
  },

  // Khi client gửi message
  message: (ws, message, isBinary) => {
    const msg = Buffer.from(message).toString();
    console.log('Received:', msg);
    // Gửi lại cho tất cả clients
    ws.publish('broadcast', msg);
  },

  // Khi client ngắt kết nối
  close: (ws, code, message) => {
    console.log('Client disconnected');
  }
});

app.listen(9001, (token) => {
  if (token) {
    console.log('Server running on port 9001');
  } else {
    console.log('Failed to listen to port 9001');
  }
});
