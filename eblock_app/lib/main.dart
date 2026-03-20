import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image/image.dart' as img;
import 'firebase_options.dart';

import 'package:tflite_flutter/tflite_flutter.dart'
    if (dart.library.html) 'dart:async' as tflite;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EBlockApp());
}

class EBlockApp extends StatelessWidget {
  const EBlockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Block Rewards',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}

// --- AUTH WRAPPER ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return const MainNavigation();
        return const LoginPage();
      },
    );
  }
}

// --- MAIN NAVIGATION ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late GlobalKey<_HomePageState> _homePageKey;

  @override
  void initState() {
    super.initState();
    _homePageKey = GlobalKey<_HomePageState>();
    _pages = [
      HomePage(key: _homePageKey),
      ScannerPage(onRewardEarned: _refreshBalance),
    ];
  }

  void _refreshBalance() {
    _homePageKey.currentState?._loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan Bin',
          ),
        ],
      ),
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _auth() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("♻️", style: TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                const Text(
                  "E-Block Rewards",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pass,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _auth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? "Login" : "Sign Up",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "Create Account" : "Login Instead",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }
}

// --- HOME PAGE (Wallet) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _balance = "Loading...";
  bool _isLoading = false;
  final String myAddress = "0x8A84C0063B1F8182841448A1AAdb92D866146445";

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _getBal();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getBal() async {
    try {
      final res = await http
          .get(Uri.parse('http://10.0.2.2:3000/api/balance/$myAddress'))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            _balance = jsonDecode(res.body)['balance'].toString();
          });
        }
      } else {
        if (mounted) {
          setState(() => _balance = "Error");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch balance")),
          );
        }
      }
    } catch (e) {
      debugPrint("Balance fetch error: $e");
      if (mounted) {
        setState(() => _balance = "Offline");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallet"),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadBalance,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Available Balance",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Text(
                      "$_balance EBR",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.arrow_downward,
                      label: "Deposit",
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionPage(
                            type: TransactionType.deposit,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.arrow_upward,
                      label: "Withdraw",
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionPage(
                            type: TransactionType.withdraw,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Address Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Wallet Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    myAddress,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            debugPrint("🚀 Simulating reward - sending to server...");
            final response = await http
                .post(
                  Uri.parse('http://10.0.2.2:3000/api/reward'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'user': myAddress,
                    'weight': 25,
                  }),
                )
                .timeout(const Duration(seconds: 5));

            debugPrint(
                "📡 Server response: ${response.statusCode} - ${response.body}");

            if (response.statusCode == 200) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ +25 EBR received!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
            await Future.delayed(const Duration(milliseconds: 500));
            await _loadBalance();
          } catch (e) {
            debugPrint("❌ Simulation failed: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        backgroundColor: Colors.amber,
        label: const Text("Simulate +25 EBR"),
        icon: const Icon(Icons.bolt),
      ),
    );
  }
}

// --- CUSTOM ACTION BUTTON ---
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TRANSACTION PAGE ---
enum TransactionType { deposit, withdraw }

class TransactionPage extends StatefulWidget {
  final TransactionType type;
  const TransactionPage({required this.type});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _amountController = TextEditingController();
  final _walletController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _processTransaction() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${widget.type == TransactionType.deposit ? "Deposit" : "Withdrawal"} of ${_amountController.text} EBR successful!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.type == TransactionType.deposit;
    final title = isDeposit ? "Deposit Tokens" : "Withdraw Tokens";
    final buttonText = isDeposit ? "Deposit" : "Withdraw";
    final color = isDeposit ? Colors.blue : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDeposit
                            ? "Add tokens to your wallet"
                            : "Send tokens from your wallet",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Amount Input
            const Text(
              "Amount (EBR)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount",
                prefixIcon: const Icon(Icons.local_offer),
                prefixText: "EBR ",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Wallet/Address Input
            Text(
              isDeposit ? "From Address" : "To Address",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _walletController,
              decoration: InputDecoration(
                hintText: "Enter wallet address",
                prefixIcon: const Icon(Icons.account_balance_wallet),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDeposit
                          ? "Processing typically takes 1-2 minutes"
                          : "Withdrawal requests are processed within 24 hours",
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _walletController.dispose();
    super.dispose();
  }
}

// --- SCANNER PAGE ---
class ScannerPage extends StatefulWidget {
  final VoidCallback? onRewardEarned;
  const ScannerPage({super.key, this.onRewardEarned});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  dynamic _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  String? _lastScannedQR;
  final MobileScannerController _controller = MobileScannerController();
  final String myAddress = "0x8A84C0063B1F8182841448A1AAdb92D866146445";
  int _rewardAmount = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadModel();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async {
    if (kIsWeb) return;
    try {
      _interpreter = await tflite.Interpreter.fromAsset('model_unquant.tflite');
      setState(() => _isModelLoaded = true);
      debugPrint("✅ Model loaded successfully");
    } catch (e) {
      debugPrint("⚠️ Error loading model: $e");
      setState(() => _isModelLoaded = false);
    }
  }

  Future<void> _addReward(int amount) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://10.0.2.2:3000/api/reward'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user': myAddress,
              'weight': amount,
            }),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint("Reward response: ${response.statusCode}");
      if (response.statusCode == 200) {
        debugPrint("✅ Reward added: $amount EBR");
      } else {
        debugPrint("❌ Failed to add reward: ${response.body}");
      }
    } catch (e) {
      debugPrint("Reward error: $e");
    }
  }

  int _generateRandomReward() {
    // Random reward between 5-50 EBR
    return 5 + (DateTime.now().millisecond % 46);
  }

  void _onDetect(BarcodeCapture capture) {
    if (kIsWeb || _isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final String qrValue = capture.barcodes.first.rawValue ?? "Unknown";

    if (_lastScannedQR == qrValue) return;
    _lastScannedQR = qrValue;

    setState(() => _isProcessing = true);
    debugPrint("📱 QR Detected: $qrValue");

    try {
      String result = "detected";
      if (_isModelLoaded && capture.image != null) {
        result = _predict(capture.image!);
      }

      // Generate and add reward
      int reward = _generateRandomReward();
      setState(() => _rewardAmount = reward);
      _addReward(reward);
      widget.onRewardEarned?.call(); // Trigger balance refresh

      _showResult(qrValue, result, reward);
    } catch (e) {
      debugPrint("❌ Detection error: $e");
      setState(() {
        _isProcessing = false;
        _lastScannedQR = null;
      });
    }
  }

  String _predict(Uint8List bytes) {
    if (_interpreter == null) return "detected";
    try {
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return "invalid";

      img.Image resized = img.copyResize(image, width: 224, height: 224);
      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (j) => List.generate(
            224,
            (k) => List.generate(3, (l) {
              var p = resized.getPixel(j, k);
              if (l == 0) return p.r / 255.0;
              if (l == 1) return p.g / 255.0;
              return p.b / 255.0;
            }),
          ),
        ),
      );

      var output = List.filled(1 * 2, 0.0).reshape([1, 2]);
      _interpreter.run(input, output);

      return output[0][0] > output[0][1] ? "valid" : "invalid";
    } catch (e) {
      debugPrint("Prediction error: $e");
      return "detected";
    }
  }

  void _showResult(String id, String res, int reward) {
    String title;
    String subtitle;
    IconData icon;

    if (res == "valid") {
      title = "✅ Valid Bin";
      subtitle = "This is a valid recycling bin";
      icon = Icons.check_circle;
    } else if (res == "invalid") {
      title = "❌ Invalid Bin";
      subtitle = "This is not a valid recycling bin";
      icon = Icons.cancel;
    } else {
      title = "📱 QR Detected";
      subtitle = "Bin code scanned successfully";
      icon = Icons.qr_code;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Reward Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber[700]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "🎉 Reward Earned!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "+$reward EBR",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Bin ID",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  SelectableText(
                    id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Scan Another",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastScannedQR = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text("QR Scanner")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 64, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Scanner Available on Mobile Only",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Download the mobile app to scan recycling bins",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text("Camera permission required"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please enable camera permissions in settings"),
                          ),
                        );
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            },
          ),
          if (!_isModelLoaded)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Loading AI model... Scanning available",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
