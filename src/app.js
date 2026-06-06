const express = require('express');
const bodyParser = require('express').json;
const userRouter = require('./routes/users');

const app = express();
app.use(bodyParser());
app.use('/api/users', userRouter);

// health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || 'internal error' });
});

module.exports = app;
