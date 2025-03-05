const express = require("express")
const mongoose = require("mongoose")
const bodyParser = require("body-parser")
const cors = require("cors")
require("dotenv").config()

const app = express()
const PORT = 4000

app.use(
  cors({
    origin: "*", // Allow all origins (for testing purposes)
    methods: ["GET", "POST", "DELETE"], // Allow GET, POST and DELETE requests
  }),
)
app.use(bodyParser.json())

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})

const userSchema = new mongoose.Schema({
  _id: Number,
  c_name: String,
  c_vill: String,
  c_category: String,
  phone: String,
})

const paymentSchema = new mongoose.Schema({
  c_id: Number,
  p_date: Date,
  p_month: String,
  amount: Number,
  transactionId: String,
  status: { type: String, enum: ["pending", "approved", "rejected"], default: "pending" },
})

const villageSchema = new mongoose.Schema({
  v_name: String,
})

const notificationSchema = new mongoose.Schema({
  userId: Number,
  message: String,
  createdAt: { type: Date, default: Date.now },
  read: { type: Boolean, default: false },
})

const transactionSchema = new mongoose.Schema({
  transactionId: String,
  userId: Number,
  month: String,
  amount: Number,
  status: { type: String, enum: ["pending", "approved", "rejected"], default: "pending" },
})

const User = mongoose.model("User", userSchema)
const Payment = mongoose.model("Payment", paymentSchema)
const Village = mongoose.model("Village", villageSchema)
const Notification = mongoose.model("Notification", notificationSchema)
const Transaction = mongoose.model("Transaction", transactionSchema)

app.post("/register_device", async (req, res) => {
  const { userId, deviceToken } = req.body
  try {
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ error: "User not found" })
    }

    user.deviceToken = deviceToken
    await user.save()

    res.json({ message: "Device registered successfully" })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

async function checkAndCreateVillage(req, res, next) {
  const { c_vill } = req.body
  try {
    const village = await Village.findOne({ v_name: c_vill })
    if (!village) {
      await Village.create({ v_name: c_vill })
    }
    next()
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}

app.post("/add_user", checkAndCreateVillage, async (req, res) => {
  const { userId, c_name, c_vill, c_category, phone } = req.body
  try {
    const existingUser = await User.findById(userId)
    if (existingUser) {
      return res.status(400).json({ error: "User ID already exists" })
    }
    const user = new User({
      _id: userId,
      c_name,
      c_vill,
      c_category,
      phone,
    })
    await user.save()

    const notification = new Notification({
      userId: userId,
      message: `Welcome ${c_name}! Your account has been created successfully.`,
    })
    await notification.save()

    res.json({ message: "User added successfully", data: user })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/pending_transactions", async (req, res) => {
  try {
    const transactions = await Transaction.find({ status: "pending" })
    res.json(transactions)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.post("/add_payments", async (req, res) => {
  const { c_id, p_month, amount } = req.body
  try {
    const user = await User.findById(c_id)
    if (!user) {
      return res.status(404).json({ error: "User not found" })
    }
    const payment = new Payment({
      c_id,
      p_date: new Date(),
      p_month,
      amount,
    })
    await payment.save()

    const notificationMessage = `Your payment of ${amount} for ${p_month} has been recorded.`

    // Create in-app notification
    const notification = new Notification({
      userId: c_id,
      message: notificationMessage,
    })
    await notification.save()

    res.json({ message: "Payment added successfully", data: payment })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/total_amount_paid", async (req, res) => {
  const userId = Number.parseInt(req.query.userId)
  try {
    const result = await Payment.aggregate([
      { $match: { c_id: userId } },
      { $group: { _id: "$c_id", total_amount: { $sum: "$amount" } } },
    ])
    const totalAmount = result.length > 0 ? result[0].total_amount : 0
    res.json({ user_id: userId, total_amount: totalAmount })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/find_user", async (req, res) => {
  const userId = Number.parseInt(req.query.userId)
  try {
    const user = await User.findById(userId)
    if (user) {
      res.json(user)
    } else {
      res.status(404).json({ error: "User not found" })
    }
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/find_payments", async (req, res) => {
  const userId = Number.parseInt(req.query.userIdPayments)
  const month = req.query.p_month

  try {
    const query = { c_id: userId }
    if (month) {
      query.p_month = month
    }

    const payments = await Payment.aggregate([
      { $match: query },
      {
        $lookup: {
          from: "users",
          localField: "c_id",
          foreignField: "_id",
          as: "customer",
        },
      },
      { $unwind: "$customer" },
      {
        $project: {
          p_id: "$_id",
          c_id: 1,
          p_month: 1,
          amount: 1,
          c_name: "$customer.c_name",
        },
      },
    ])
    res.json(payments)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/view_payments_by_month", async (req, res) => {
  const month = req.query.p_month
  try {
    // Get all users
    const allUsers = await User.find().sort({ _id: 1 })

    // Get all payments for the specified month
    const payments = await Payment.find({ p_month: month })

    // Create a map of user IDs who have paid
    const paidUserIds = new Set(payments.map((payment) => payment.c_id))

    // Separate users into paid and unpaid
    const paidUsers = []
    const unpaidUsers = []

    for (const user of allUsers) {
      if (paidUserIds.has(user._id)) {
        // Find the payment for this user
        const payment = payments.find((p) => p.c_id === user._id)
        paidUsers.push({
          _id: user._id,
          c_name: user.c_name,
          c_vill: user.c_vill,
          c_category: user.c_category,
          amount: payment ? payment.amount : 0,
        })
      } else {
        unpaidUsers.push({
          _id: user._id,
          c_name: user.c_name,
          c_vill: user.c_vill,
          c_category: user.c_category,
        })
      }
    }

    // Sort both arrays by ID
    paidUsers.sort((a, b) => a._id - b._id)
    unpaidUsers.sort((a, b) => a._id - b._id)

    res.json({
      paidCount: paidUsers.length,
      unpaidCount: unpaidUsers.length,
      totalCount: allUsers.length,
      paidUsers,
      unpaidUsers,
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/find_all_users", async (req, res) => {
  try {
    const users = await User.find().sort({ _id: 1 })

    // Get payment counts for each user
    const userIds = users.map((user) => user._id)
    const paymentCounts = await Payment.aggregate([
      { $match: { c_id: { $in: userIds } } },
      { $group: { _id: "$c_id", count: { $sum: 1 } } },
    ])

    // Create a map of user ID to payment count
    const paymentCountMap = {}
    paymentCounts.forEach((item) => {
      paymentCountMap[item._id] = item.count
    })

    // Add payment count to each user
    const usersWithPaymentCount = users.map((user) => {
      const userObj = user.toObject()
      userObj.paymentCount = paymentCountMap[user._id] || 0
      return userObj
    })

    res.json({
      totalCount: users.length,
      users: usersWithPaymentCount,
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/search_users", async (req, res) => {
  const { name, c_category, c_vill } = req.query
  try {
    const query = {}
    if (name) query.c_name = new RegExp(name, "i")
    if (c_category) query.c_category = new RegExp(c_category, "i")
    if (c_vill) query.c_vill = new RegExp(c_vill, "i")

    const users = await User.find(query).sort({ _id: 1 })
    res.json(users)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/get_all_villages", async (req, res) => {
  try {
    const villages = await Village.find().sort({ v_name: 1 })
    res.json(villages)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/search_by_village", async (req, res) => {
  const { village } = req.query
  try {
    if (!village) {
      return res.status(400).json({ error: "Village name is required" })
    }

    const users = await User.find({ c_vill: village }).sort({ _id: 1 })

    // Get payment counts for each user
    const userIds = users.map((user) => user._id)
    const paymentCounts = await Payment.aggregate([
      { $match: { c_id: { $in: userIds } } },
      { $group: { _id: "$c_id", count: { $sum: 1 } } },
    ])

    // Create a map of user ID to payment count
    const paymentCountMap = {}
    paymentCounts.forEach((item) => {
      paymentCountMap[item._id] = item.count
    })

    // Add payment count to each user
    const usersWithPaymentCount = users.map((user) => {
      const userObj = user.toObject()
      userObj.paymentCount = paymentCountMap[user._id] || 0
      return userObj
    })

    res.json({
      village,
      count: users.length,
      users: usersWithPaymentCount,
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/inactive_customers", async (req, res) => {
  try {
    // Get all users
    const allUsers = await User.find()

    // Get current date and calculate 2 months ago
    const currentDate = new Date()
    const twoMonthsAgo = new Date()
    twoMonthsAgo.setMonth(currentDate.getMonth() - 2)

    const inactiveUsers = []

    // For each user, check their last payment
    for (const user of allUsers) {
      // Get the latest payment for this user
      const latestPayment = await Payment.findOne({ c_id: user._id }).sort({ p_date: -1 }).limit(1)

      // If no payment or last payment is older than 2 months, consider inactive
      if (!latestPayment || new Date(latestPayment.p_date) < twoMonthsAgo) {
        inactiveUsers.push({
          id: user._id,
          name: user.c_name,
          phone: user.phone,
          village: user.c_vill,
          category: user.c_category,
          lastPaymentMonth: latestPayment ? latestPayment.p_month : "Never",
          lastPaymentAmount: latestPayment ? latestPayment.amount : 0,
        })
      }
    }

    // Sort by ID
    inactiveUsers.sort((a, b) => a.id - b.id)

    res.json({
      count: inactiveUsers.length,
      inactiveUsers,
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.delete("/delete_user/:userId", async (req, res) => {
  const userId = Number.parseInt(req.params.userId)
  try {
    // First check if the user exists
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ error: "User not found" })
    }

    // Delete the user
    await User.findByIdAndDelete(userId)

    // Delete related records
    await Payment.deleteMany({ c_id: userId })
    await Notification.deleteMany({ userId: userId })
    await Transaction.deleteMany({ userId: userId })

    res.json({ message: `User with ID ${userId} and their related data were deleted successfully` })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.post("/login", async (req, res) => {
  const { username, password } = req.body
  try {
    if (username === process.env.ADMIN_USERNAME && password === process.env.ADMIN_PASSWORD) {
      return res.json({ success: true, isAdmin: true })
    }

    const user = await User.findOne({ _id: username, phone: password })
    if (user) {
      res.json({ success: true, isAdmin: false, userId: user._id })
    } else {
      res.status(401).json({ error: "Invalid credentials" })
    }
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.get("/notifications/:userId", async (req, res) => {
  const userId = Number.parseInt(req.params.userId)
  try {
    const notifications = await Notification.find({ userId }).sort({ createdAt: -1 })
    res.json(notifications)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.post("/request_payment", async (req, res) => {
  const { userId, month, amount, transactionId } = req.body
  try {
    const existingPayment = await Payment.findOne({ c_id: userId, p_month: month })
    if (existingPayment) {
      return res.status(400).json({ error: "Payment for this month already exists" })
    }

    const existingTransaction = await Transaction.findOne({ transactionId })
    if (existingTransaction) {
      return res.status(400).json({ error: "Transaction ID already exists" })
    }

    const transaction = new Transaction({
      transactionId,
      userId,
      month,
      amount,
      status: "pending",
    })
    await transaction.save()

    // Create in-app notification
    const notificationMessage = `Your payment request of ${amount} for ${month} has been submitted and is pending approval.`
    const notification = new Notification({
      userId,
      message: notificationMessage,
    })
    await notification.save()

    res.json({ message: "Payment request submitted successfully", data: transaction })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.post("/approve_payment", async (req, res) => {
  const { transactionId } = req.body
  try {
    const transaction = await Transaction.findOne({ transactionId })
    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found" })
    }

    transaction.status = "approved"
    await transaction.save()

    const payment = new Payment({
      c_id: transaction.userId,
      p_date: new Date(),
      p_month: transaction.month,
      amount: transaction.amount,
      transactionId: transaction.transactionId,
    })
    await payment.save()

    // Create in-app notification
    const notificationMessage = `Your payment of ${transaction.amount} for ${transaction.month} has been approved.`
    const notification = new Notification({
      userId: transaction.userId,
      message: notificationMessage,
    })
    await notification.save()

    res.json({ message: "Payment approved successfully", data: payment })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.post("/reject_payment", async (req, res) => {
  const { transactionId } = req.body
  try {
    const transaction = await Transaction.findOne({ transactionId })
    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found" })
    }

    transaction.status = "rejected"
    await transaction.save()

    // Create in-app notification
    const notificationMessage = `Your payment of ${transaction.amount} for ${transaction.month} has been rejected.`
    const notification = new Notification({
      userId: transaction.userId,
      message: notificationMessage,
    })
    await notification.save()

    res.json({ message: "Payment rejected successfully", data: transaction })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

app.listen(PORT, () => {
  console.log(`Server running on port http://localhost:${PORT}`)
})

