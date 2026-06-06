const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const User = require('../src/models/User');

let mongoServer;
beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

afterEach(async () => {
  await User.deleteMany({});
});

test('POST /api/users -> create user', async () => {
  const res = await request(app)
    .post('/api/users')
    .send({ name: 'Akhil', email: 'akhil@example.com' })
    .expect(201);

  expect(res.body).toHaveProperty('_id');
  expect(res.body.name).toBe('Akhil');
});

test('GET /api/users -> list users', async () => {
  await User.create({ name: 'A', email: 'a@example.com' });
  await User.create({ name: 'B', email: 'b@example.com' });

  const res = await request(app).get('/api/users').expect(200);
  expect(Array.isArray(res.body)).toBe(true);
  expect(res.body.length).toBe(2);
});

test('GET /api/users/:id -> 404 for missing', async () => {
  await request(app).get('/api/users/507f1f77bcf86cd799439011').expect(404);
});
