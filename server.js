const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();
const app = express();
const PORT = 4000;

app.use(cors());
app.use(bodyParser.json());

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const userSchema = new mongoose.Schema({
  _id: Number,
  c_name: String,
  c_vill: String,
  c_category: String,
  phone: String,
});

const paymentSchema = new mongoose.Schema({
  c_id: Number,
  p_date: Date,
  p_month: String,
  amount: Number,
});

const villageSchema = new mongoose.Schema({
  v_name: String,
});

const notificationSchema = new mongoose.Schema({
  userId: Number,
  message: String,
  createdAt: { type: Date, default: Date.now },
  read: { type: Boolean, default: false },
});

const User = mongoose.model('User', userSchema);
const Payment = mongoose.model('Payment', paymentSchema);
const Village = mongoose.model('Village', villageSchema);
const Notification = mongoose.model('Notification', notificationSchema);

async function checkAndCreateVillage(req, res, next) {
  const { c_vill } = req.body;
  try {
    const village = await Village.findOne({ v_name: c_vill });
    if (!village) {
      await Village.create({ v_name: c_vill });
    }
    next();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

app.post('/add_user', checkAndCreateVillage, async (req, res) => {
  const { userId, c_name, c_vill, c_category, phone } = req.body;
  try {
    const existingUser = await User.findById(userId);
    if (existingUser) {
      return res.status(400).json({ error: "User ID already exists" });
    }
    const user = new User({
      _id: userId,
      c_name,
      c_vill,
      c_category,
      phone
    });
    await user.save();
    
    // Create a notification for the new user
    const notification = new Notification({
      userId: userId,
      message: `Welcome ${c_name}! Your account has been created successfully.`,
    });
    await notification.save();
    
    res.json({ message: 'User added successfully', data: user });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/add_payments', async (req, res) => {
  const { c_id, p_month, amount } = req.body;
  try {
    const user = await User.findById(c_id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    const payment = new Payment({
      c_id,
      p_date: new Date(),
      p_month,
      amount
    });
    await payment.save();
    
    // Create a notification for the payment
    const notification = new Notification({
      userId: c_id,
      message: `Your payment of ${amount} for ${p_month} has been recorded.`,
    });
    await notification.save();
    
    res.json({ message: 'Payment added successfully', data: payment });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/total_amount_paid', async (req, res) => {
  const userId = parseInt(req.query.userId);
  try {
    const result = await Payment.aggregate([
      { $match: { c_id: userId } },
      { $group: { _id: '$c_id', total_amount: { $sum: '$amount' } } }
    ]);
    const totalAmount = result.length > 0 ? result[0].total_amount : 0;
    res.json({ user_id: userId, total_amount: totalAmount });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/find_user', async (req, res) => {
  const userId = parseInt(req.query.userId);
  try {
    const user = await User.findById(userId);
    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ error: "User not found" });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/find_payments', async (req, res) => {
  const userId = parseInt(req.query.userIdPayments);
  try {
    const payments = await Payment.aggregate([
      { $match: { c_id: userId } },
      { $lookup: {
          from: 'users',
          localField: 'c_id',
          foreignField: '_id',
          as: 'customer'
        }
      },
      { $unwind: '$customer' },
      { $project: {
          p_id: '$_id',
          c_id: 1,
          p_month: 1,
          amount: 1,
          c_name: '$customer.c_name'
        }
      }
    ]);
    res.json(payments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/view_payments_by_month', async (req, res) => {
  const month = req.query.p_month;
  try {
    const payments = await Payment.aggregate([
      { $match: { p_month: month } },
      { $lookup: {
          from: 'users',
          localField: 'c_id',
          foreignField: '_id',
          as: 'customer'
        }
      },
      { $unwind: '$customer' },
      { $project: {
          p_id: '$_id',
          c_id: 1,
          p_month: 1,
          amount: 1,
          c_name: '$customer.c_name'
        }
      }
    ]);
    res.json(payments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/find_all_users', async (req, res) => {
  try {
    const users = await User.find().sort({ _id: 1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/search_users', async (req, res) => {
  const { name, c_category, c_vill } = req.query;
  try {
    let query = {};
    if (name) query.c_name = new RegExp(name, 'i');
    if (c_category) query.c_category = new RegExp(c_category, 'i');
    if (c_vill) query.c_vill = new RegExp(c_vill, 'i');

    const users = await User.find(query).sort({ _id: 1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/delete_user/:userId', async (req, res) => {
  const userId = parseInt(req.params.userId);
  try {
    const deletedUser = await User.findByIdAndDelete(userId);
    if (!deletedUser) {
      return res.status(404).json({ error: "User not found" });
    }

    await Payment.deleteMany({ c_id: userId });
    await Notification.deleteMany({ userId: userId });

    res.json({ message: `User with ID ${userId} and their payments were deleted successfully` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    // Check for admin login first
    if (username === process.env.ADMIN_USERNAME && password === process.env.ADMIn_PASSWORD) {
      return res.json({ success: true, isAdmin: true });
    }
    
    // If not admin, check for regular user
    const user = await User.findOne({ _id: username, phone: password });
    if (user) {
      res.json({ success: true, isAdmin: false, userId: user._id });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/notifications/:userId', async (req, res) => {
  const userId = parseInt(req.params.userId);
  try {
    const notifications = await Notification.find({ userId }).sort({ createdAt: -1 });
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port http://localhost:${PORT}`);
});

