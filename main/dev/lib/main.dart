import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    bool? isAdmin = prefs.getBool('isAdmin');

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(username: username, isAdmin: isAdmin)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/jerry.gif',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String? username;
  final bool? isAdmin;
  
  HomeScreen({this.username, this.isAdmin});

  final String shopName = "Sri SivaSakthi Stores";
  final String ownerName = "Mr. Madhu Kumar";
  final String phoneNumber = "+91 9080660749";
  final String serviceDescription = "Specialized in Diwali Chits with various categories to choose from.";
  final String address = "Sri SivaSakthi Stores, Konganapalli Road, Opposite to Aishwarya Hotel, Veppanapalli 635 121";
  final String mapUrl = "https://maps.app.goo.gl/44evAN22mo1KNfTc7";

  final List<Map<String, dynamic>> categories = [
  {
    "title": "Gold",
    "amount": "₹500 per month",
    "color": "blue",
    "products": [
      {"name": "Rice", "quantity": "25 Kg", "image": "assets/things/ricejpg.jpg"},
      {"name": "Maida", "quantity": "1 Pack", "image": "assets/things/maida.jpg"},
      {"name": "Oil", "quantity": "5 Liters", "image": "assets/things/oil.jpg"},
      {"name": "Wheat Flour", "quantity": "1 Pack", "image": "assets/things/atta.jpg"},
      {"name": "White Dhall", "quantity": "3 Kg", "image": "assets/things/whitedall.jpg"},
      {"name": "Rice Raw", "quantity": "3 Kg", "image": "assets/things/riceraw.jpg"},
      {"name": "Semiya", "quantity": "1 Pack", "image": "assets/things/semiya.jpg"},
      {"name": "Payasam Mix", "quantity": "1 Pack", "image": "assets/things/payasam.jpg"},
      {"name": "Sugar", "quantity": "1 Kg", "image": "assets/things/sugar.jpg"},
      {"name": "Sesame Oil", "quantity": "150 grams", "image": "assets/things/sesame.jpg"},
      {"name": "Tamarind", "quantity": "25 pieces", "image": "assets/things/tamrind.jpg"},
      {"name": "Dry Chilli", "quantity": "25 pieces", "image": "assets/things/chilly.jpg"},
      {"name": "Coriander Seeds", "quantity": "11 pieces", "image": "assets/things/coriander.jpg"},
      {"name": "Salt", "quantity": "1/2 Kg", "image": "assets/things/salt.jpg"},
      {"name": "Jaggery", "quantity": "1/2 Kg", "image": "assets/things/jaggery.jpg"},
      {"name": "Pattasu Box", "quantity": "1 Box", "image": "assets/things/pattasu.jpg"},
      {"name": "Matches Box", "quantity": "1 Pack", "image": "assets/things/matchjpg.jpg"},
      {"name": "Turmeric Powder", "quantity": "1 Pack", "image": "assets/things/tumeric.jpg"},
      {"name": "Kumkum", "quantity": "1 Pack", "image": "assets/things/kumkumjpg.jpg"},
      {"name": "Camphor", "quantity": "1 Pack", "image": "assets/things/camphor.jpg"}
    ],
  },
  {
    "title": "Silver",
    "amount": "₹300 per month",
    "color": "yellow",
    "products": [
      {"name": "Rice", "quantity": "5 Kg", "image": "assets/things/ricejpg.jpg"},
      {"name": "Oil", "quantity": "5 Liters", "image": "assets/things/oil.jpg"},
      {"name": "White Dhall", "quantity": "5 Kg", "image": "assets/things/whitedall.jpg"},
      {"name": "Sesame Oil", "quantity": "250 grams", "image": "assets/things/sesame.jpg"},
      {"name": "Tamarind", "quantity": "25 pieces", "image": "assets/things/tamrind.jpg"},
      {"name": "Dry Chilli", "quantity": "25 pieces", "image": "assets/things/chilly.jpg"},
      {"name": "Coriander Seeds", "quantity": "11 pieces", "image": "assets/things/coriander.jpg"},
      {"name": "Maida", "quantity": "5 Kg", "image": "assets/things/maida.jpg"},
      {"name": "Wheat Flour", "quantity": "5 Kg", "image": "assets/things/atta.jpg"},
      {"name": "Oil", "quantity": "1/2 Liter", "image": "assets/things/oil.jpg"},
      {"name": "Semiya", "quantity": "1 Pack", "image": "assets/things/semiya.jpg"},
      {"name": "Matches Box", "quantity": "1 Pack", "image": "assets/things/matchjpg.jpg"},
      {"name": "Turmeric Powder", "quantity": "1 Pack", "image": "assets/things/tumeric.jpg"},
      {"name": "Kumkum", "quantity": "1 Pack", "image": "assets/things/kumkumjpg.jpg"},
      {"name": "Camphor", "quantity": "1 Pack", "image": "assets/things/camphor.jpg"}
    ],
  }
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (username != null)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isAdmin == true
                        ? AdminScreen()
                        : UserScreen(username: username!),
                  ),
                );
              },
              child: Text('Actions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/shop.jpg', height: 150, fit: BoxFit.cover),
                    const SizedBox(height: 10),
                    Text(
                      shopName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildPersonCard('Nanjappan', 'Honoured', 'assets/father.jpg'),
                  buildPersonCard(ownerName, 'Owner', 'assets/owner.jpg'),
                  buildPersonCard('Suselamma', 'Honoured', 'assets/mother.jpg'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Address:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(address),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(mapUrl)) {
                    await launch(mapUrl);
                  } else {
                    throw 'Could not launch $mapUrl';
                  }
                },
                child: const Text('View on Map'),
              ),
              const SizedBox(height: 10),
              Text("Phone: $phoneNumber"),
              const SizedBox(height: 20),
              Text(serviceDescription),
              const SizedBox(height: 20),
              const Text('Categories:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: categories.map((category) {
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(category['title']),
                      subtitle: Text(category['amount']),
                      trailing: ElevatedButton(
                        child: const Text('View More'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailsPage(category: category),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPersonCard(String name, String role, String imagePath) {
    return Column(
      children: [
        Image.asset(imagePath, height: 100, fit: BoxFit.cover),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class CategoryDetailsPage extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryDetailsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category['title']),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              category['amount'],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Products:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: category['products'].length,
                itemBuilder: (context, index) {
                  final product = category['products'][index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: ListTile(
                      leading: Image.network(product['image'], height: 1800, fit: BoxFit.cover),
                      title: Text(product['name']),
                      subtitle: Text(product['quantity']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final response = await http.post(
          Uri.parse('https://consultancy-project-coral.vercel.app/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': _username, 'password': _password}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success']) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', _username);
            await prefs.setBool('isAdmin', data['isAdmin']);

            // Register for push notifications
            

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(username: _username, isAdmin: data['isAdmin'])),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid credentials. Please try again.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'User ID'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your User ID' : null,
                onSaved: (value) => _username = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Admin!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOperationsScreen()),
                );
              },
              child: Text('Operations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPaymentApprovalScreen()),
                );
              },
              child: Text('Pending Payments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPaymentApprovalScreen extends StatefulWidget {
  @override
  _AdminPaymentApprovalScreenState createState() => _AdminPaymentApprovalScreenState();
}

class _AdminPaymentApprovalScreenState extends State<AdminPaymentApprovalScreen> {
  List<Map<String, dynamic>> _pendingTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingTransactions(); // Fetch pending transactions when the screen loads
  }

  Future<void> _fetchPendingTransactions() async {
  try {
    final url = Uri.parse('https://consultancy-project-coral.vercel.app/pending_transactions');
    print('Sending request to: $url'); // Log the request URL

    final response = await http.get(url);

    print('Response status code: ${response.statusCode}'); // Log the status code
    print('Response body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      final transactions = json.decode(response.body);
      print('Transactions found: ${transactions.length}'); // Log the number of transactions
      setState(() {
        _pendingTransactions = List<Map<String, dynamic>>.from(transactions);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch pending transactions: ${response.body}')),
      );
    }
  } catch (e) {
    print('Error: $e'); // Log the error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}
  Future<void> _approvePayment(String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('https://consultancy-project-coral.vercel.app/approve_payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'transactionId': transactionId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment approved successfully')),
        );
        _fetchPendingTransactions(); // Refresh the list after approval
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve payment: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _rejectPayment(String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('https://consultancy-project-coral.vercel.app/reject_payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'transactionId': transactionId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment rejected successfully')),
        );
        _fetchPendingTransactions(); // Refresh the list after rejection
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject payment: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Payment Requests'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _pendingTransactions.isEmpty
          ? Center(child: Text('No pending payment requests.'))
          : ListView.builder(
              itemCount: _pendingTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _pendingTransactions[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('User ID: ${transaction['userId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Month: ${transaction['month']}'),
                        Text('Amount: ₹${transaction['amount']}'),
                        Text('Transaction ID: ${transaction['transactionId']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approvePayment(transaction['transactionId']),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectPayment(transaction['transactionId']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AdminOperationsScreen extends StatefulWidget {
  @override
  _AdminOperationsScreenState createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  String _selectedCategory = 'Gold';
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _monthController = TextEditingController();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _paidUsers = [];
  List<Map<String, dynamic>> _unpaidUsers = [];
  List<String> _villages = [];
  String _selectedVillage = '';
  List<Map<String, dynamic>> _villageUsers = [];
  List<Map<String, dynamic>> _inactiveUsers = [];
  
  String _selectedOperation = '';
  Map<String, dynamic> _userToDelete = {};

  List<String> categories = ['Gold', 'Silver', 'Bronze'];

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _monthController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVillages() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/get_all_villages'),
      );

      if (response.statusCode == 200) {
        final villages = json.decode(response.body);
        setState(() {
          _villages = List<String>.from(villages.map((v) => v['v_name']));
          if (_villages.isNotEmpty && _selectedVillage.isEmpty) {
            _selectedVillage = _villages[0];
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch villages: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _searchByVillage() async {
    if (_selectedVillage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a village')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/search_by_village?village=${_selectedVillage}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _villageUsers = List<Map<String, dynamic>>.from(data['users']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to search by village: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _fetchInactiveCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/inactive_customers'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _inactiveUsers = List<Map<String, dynamic>>.from(data['inactiveUsers']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch inactive customers: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://consultancy-project-coral.vercel.app/add_user'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': int.parse(_userIdController.text),
            'c_name': _nameController.text,
            'c_vill': _villageController.text,
            'c_category': _selectedCategory,
            'phone': _phoneController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User added successfully')),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add user: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<void> _fetchUserDetailsForDeletion() async {
    if (_userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a User ID to delete')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_user?userId=${_userIdController.text}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _userToDelete = json.decode(response.body);
        });
        
        // Show confirmation dialog
        _showDeleteConfirmationDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this user?'),
              SizedBox(height: 20),
              Text('User Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('ID: ${_userToDelete['_id']}'),
              Text('Name: ${_userToDelete['c_name']}'),
              Text('Village: ${_userToDelete['c_vill']}'),
              Text('Category: ${_userToDelete['c_category']}'),
              Text('Phone: ${_userToDelete['phone']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteUser(); // Proceed with deletion
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser() async {
    try {
      final response = await http.delete(
        Uri.parse('https://consultancy-project-coral.vercel.app/delete_user/${_userIdController.text}'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _viewAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_all_users'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['users']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch users: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _addPayment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://consultancy-project-coral.vercel.app/add_payments'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'c_id': int.parse(_userIdController.text),
            'p_month': _monthController.text,
            'amount': double.parse(_amountController.text),
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment added successfully')),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add payment: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<void> _viewPayments() async {
    if (_userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a User ID to view payments')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_payments?userIdPayments=${_userIdController.text}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _payments = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch payments: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _viewPaymentsByMonth() async {
    if (_monthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a month to view payments')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/view_payments_by_month?p_month=${_monthController.text}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _paidUsers = List<Map<String, dynamic>>.from(data['paidUsers']);
          _unpaidUsers = List<Map<String, dynamic>>.from(data['unpaidUsers']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch payments: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _fetchUserDetails() async {
    if (_userIdController.text.isEmpty) {
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_user?userId=${_userIdController.text}'),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _nameController.text = userData['c_name'];
          _selectedCategory = userData['c_category'];
          switch (_selectedCategory) {
            case 'Gold':
              _amountController.text = '500';
              break;
            case 'Silver':
              _amountController.text = '300';
              break;
            default:
              _amountController.text = '';
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _clearForm() {
    _userIdController.clear();
    _nameController.clear();
    _villageController.clear();
    _selectedCategory = 'Gold';
    _phoneController.clear();
    _amountController.clear();
    _monthController.clear();
  }

  Widget _buildOperationButton(String operation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedOperation = operation;
            _clearForm();
            
            // Initialize data for specific operations
            if (operation == 'Search\nBy\nVillage') {
              _fetchVillages();
            } else if (operation == 'Inactive\nCustomers') {
              _fetchInactiveCustomers();
            }
          });
        },
        child: Text(operation),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedOperation == operation ? Colors.deepPurple : Colors.grey,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildOperationContent() {
    switch (_selectedOperation) {
      case 'Add\nUser':
        return _buildAddUserForm();
      case 'Delete\nUser':
        return _buildDeleteUserForm();
      case 'View\nAll\nUsers':
        return _buildViewAllUsersContent();
      case 'Add\nPayment':
        return _buildAddPaymentForm();
      case 'View\nPayments':
        return _buildViewPaymentsContent();
      case 'View\nPayments\nby\nMonth':
        return _buildViewPaymentsByMonthContent();
      case 'Search\nBy\nVillage':
        return _buildSearchByVillageContent();
      case 'Inactive\nCustomers':
        return _buildInactiveCustomersContent();
      default:
        return Container();
    }
  }

  Widget _buildAddUserForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _userIdController,
            decoration: InputDecoration(labelText: 'User ID'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Please enter a user ID' : null,
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          TextFormField(
            controller: _villageController,
            decoration: InputDecoration(labelText: 'Village'),
            validator: (value) => value!.isEmpty ? 'Please enter a village' : null,
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(labelText: 'Category'),
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addUser,
            child: Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteUserForm() {
    return Column(
      children: [
        TextFormField(
          controller: _userIdController,
          decoration: InputDecoration(labelText: 'User ID'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _fetchUserDetailsForDeletion,
          child: Text('Delete User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllUsersContent() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _viewAllUsers,
          child: Text('Refresh Users List'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        if (_users.isNotEmpty)
          Text(
            'Total Users: ${_users.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        SizedBox(height: 10),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Users',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              // Filter users based on search text
              if (value.isEmpty) {
                _viewAllUsers(); // Refresh the list if search is cleared
              } else {
                _users = _users.where((user) =>
                  user['c_name'].toString().toLowerCase().contains(value.toLowerCase()) ||
                  user['c_vill'].toString().toLowerCase().contains(value.toLowerCase()) ||
                  user['c_category'].toString().toLowerCase().contains(value.toLowerCase()) ||
                  user['_id'].toString().contains(value)
                ).toList();
              }
            });
          },
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                title: Text('${user['_id']} - ${user['c_name']}'),
                subtitle: Text('Village: ${user['c_vill']}, Category: ${user['c_category']}'),
                trailing: Text('Payments: ${user['paymentCount']}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _userIdController,
            decoration: InputDecoration(labelText: 'User ID'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Please enter a user ID' : null,
            onChanged: (_) => _fetchUserDetails(),
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            readOnly: true,
          ),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
          ),
          TextFormField(
            controller: _monthController,
            decoration: InputDecoration(labelText: 'Month'),
            validator: (value) => value!.isEmpty ? 'Please enter a month' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addPayment,
            child: Text('Add Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewPaymentsContent() {
    return Column(
      children: [
        TextFormField(
          controller: _userIdController,
          decoration: InputDecoration(labelText: 'User ID'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _viewPayments,
          child: Text('View Payments'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              return ListTile(
                title: Text('Amount: ${payment['amount']}'),
                subtitle: Text('Month: ${payment['p_month']}, User: ${payment['c_name']}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewPaymentsByMonthContent() {
    return Column(
      children: [
        TextFormField(
          controller: _monthController,
          decoration: InputDecoration(labelText: 'Month (e.g., 01 for January)'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _viewPaymentsByMonth,
          child: Text('View Payments by Month'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        if (_paidUsers.isNotEmpty || _unpaidUsers.isNotEmpty)
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Paid (${_paidUsers.length})'),
                      Tab(text: 'Unpaid (${_unpaidUsers.length})'),
                    ],
                    labelColor: Colors.deepPurple,
                    unselectedLabelColor: Colors.grey,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Paid Users Tab
                        _buildUserList(_paidUsers, true),
                        // Unpaid Users Tab
                        _buildUserList(_unpaidUsers, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, bool isPaid) {
    return users.isEmpty
        ? Center(child: Text('No ${isPaid ? 'paid' : 'unpaid'} users for this month'))
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPaid ? Colors.green[100] : Colors.red[100],
                    child: Text('${index + 1}'),
                  ),
                  title: Text('ID: ${user['_id']} - ${user['c_name']}'),
                  subtitle: Text('Village: ${user['c_vill']}, Category: ${user['c_category']}'),
                  trailing: isPaid
                      ? Text('₹${user['amount']}', style: TextStyle(fontWeight: FontWeight.bold))
                      : null,
                ),
              );
            },
          );
  }

  Widget _buildSearchByVillageContent() {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedVillage.isNotEmpty ? _selectedVillage : null,
          hint: Text('Select Village'),
          isExpanded: true,
          items: _villages.map((String village) {
            return DropdownMenuItem<String>(
              value: village,
              child: Text(village),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedVillage = newValue!;
            });
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _searchByVillage,
          child: Text('Search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        if (_villageUsers.isNotEmpty)
          Text(
            'Customers in ${_selectedVillage}: ${_villageUsers.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _villageUsers.length,
            itemBuilder: (context, index) {
              final user = _villageUsers[index];
              return ListTile(
                title: Text('ID: ${user['_id']} - ${user['c_name']}'),
                subtitle: Text('Category: ${user['c_category']}'),
                trailing: Text('Payments: ${user['paymentCount']}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveCustomersContent() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _fetchInactiveCustomers,
          child: Text('Refresh Inactive Customers'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        if (_inactiveUsers.isNotEmpty)
          Text(
            'Inactive Customers: ${_inactiveUsers.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _inactiveUsers.length,
            itemBuilder: (context, index) {
              final user = _inactiveUsers[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text('ID: ${user['id']} - ${user['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${user['phone']}'),
                      Text('Village: ${user['village']}, Category: ${user['category']}'),
                      Text('Last Payment: ${user['lastPaymentMonth']}'),
                    ],
                  ),
                  trailing: Text('₹${user['lastPaymentAmount']}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Operations'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: ListView(
                padding: EdgeInsets.all(8.0),
                children: [
                  _buildOperationButton('Add\nUser'),
                  _buildOperationButton('Delete\nUser'),
                  _buildOperationButton('View\nAll\nUsers'),
                  _buildOperationButton('Add\nPayment'),
                  _buildOperationButton('View\nPayments'),
                  _buildOperationButton('View\nPayments\nby\nMonth'),
                  _buildOperationButton('Search\nBy\nVillage'),
                  _buildOperationButton('Inactive\nCustomers'),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildOperationContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class UserScreen extends StatefulWidget {
  final String username;

  UserScreen({required this.username});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map<String, dynamic> _userDetails = {};
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchPayments();
    _fetchNotifications();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_user?userId=${widget.username}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _userDetails = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _fetchPayments() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_payments?userIdPayments=${widget.username}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _payments = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch payments: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/notifications/${widget.username}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch notifications: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen(notifications: _notifications)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.payment), // Add a payment icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen(username: widget.username)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${_userDetails['c_name'] ?? widget.username}!', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('User Details:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('ID: ${_userDetails['_id'] ?? 'N/A'}'),
              Text('Name: ${_userDetails['c_name'] ?? 'N/A'}'),
              Text('Village: ${_userDetails['c_vill'] ?? 'N/A'}'),
              Text('Phone: ${_userDetails['phone'] ?? 'N/A'}'),
              Text('Category: ${_userDetails['c_category'] ?? 'N/A'}'),
              SizedBox(height: 20),
              Text('Payment History:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _payments.isEmpty
                ? Text('No payments found.')
                : Column(
                    children: _payments.map((payment) => ListTile(
                      title: Text('Amount: ${payment['amount']}'),
                      subtitle: Text('Month: ${payment['p_month']}'),
                    )).toList(),
                  ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  NotificationsScreen({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification['message']),
            subtitle: Text(DateTime.parse(notification['createdAt']).toString()),
          );
        },
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final String username;

  PaymentScreen({required this.username});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _transactionIdController = TextEditingController();
  bool _isPaid = false;
  Map<String, dynamic> _userDetails = {};
  String _selectedMonth = '01'; // Default selected month

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://consultancy-project-coral.vercel.app/find_user?userId=${widget.username}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _userDetails = json.decode(response.body);
        });
        // Check payment status for the default month after fetching user details
        _checkPaymentStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final url = Uri.parse(
        'https://consultancy-project-coral.vercel.app/check_payment_status?userId=${widget.username}&month=$_selectedMonth',
      );
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isPaid = data['isPaid'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check payment status: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _requestPayment() async {
    if (_transactionIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a transaction ID')),
      );
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('https://consultancy-project-coral.vercel.app/request_payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': int.parse(widget.username),
          'month': _selectedMonth,
          'amount': _userDetails['c_category'] == 'Gold' ? 500 : 300,
          'transactionId': _transactionIdController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment request submitted successfully')),
        );
        // Refresh payment status after submitting
        _checkPaymentStatus();
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to submit payment request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedMonth,
              items: List.generate(12, (index) {
                final month = (index + 1).toString().padLeft(2, '0'); // 01, 02, ..., 12
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text('Month $month'),
                );
              }),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMonth = newValue!;
                });
                _checkPaymentStatus(); // Check payment status for the selected month
              },
            ),
            SizedBox(height: 20),
            _isPaid
              ? Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 10),
                      Text(
                        'Payment for month $_selectedMonth is already made.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Image.asset('assets/things/image.jpg', height: 200),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _transactionIdController,
                      decoration: InputDecoration(labelText: 'Transaction ID'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _requestPayment,
                      child: Text('Submit Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}