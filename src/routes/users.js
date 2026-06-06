const express = require('express');
const User = require('../models/User');

const router = express.Router();

// create
router.post('/', async (req, res, next) => {
  try {
    const u = new User(req.body);
    const saved = await u.save();
    res.status(201).json(saved);
  } catch (err) { next(err); }
});

// list
router.get('/', async (req, res, next) => {
  try {
    const users = await User.find().limit(100);
    res.json(users);
  } catch (err) { next(err); }
});

// get
router.get('/:id', async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'Not found' });
    res.json(user);
  } catch (err) { next(err); }
});

// update
router.put('/:id', async (req, res, next) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!user) return res.status(404).json({ message: 'Not found' });
    res.json(user);
  } catch (err) { next(err); }
});

// delete
router.delete('/:id', async (req, res, next) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.status(204).end();
  } catch (err) { next(err); }
});

module.exports = router;
