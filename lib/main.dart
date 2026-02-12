import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zikr Matik',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B132B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE0B973),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isVibrationOn = true;
  bool _isSoundOn = false;

  void _incrementCounter() {
    if (_isVibrationOn) {
      HapticFeedback.lightImpact();
    }

    // Şimdilik gerçek ses yok (ileride package ekleyeceğiz)
    if (_isSoundOn) {
      debugPrint("Click sound");
    }

    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B132B),
        elevation: 0,
        title: const Text(
          "Zikr Matik",
          style: TextStyle(
            color: Color(0xFFE0B973),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVibrationOn ? Icons.vibration : Icons.vibration_outlined,
              color: const Color(0xFFE0B973),
            ),
            onPressed: () {
              setState(() {
                _isVibrationOn = !_isVibrationOn;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _isSoundOn ? Icons.volume_up : Icons.volume_off,
              color: const Color(0xFFE0B973),
            ),
            onPressed: () {
              setState(() {
                _isSoundOn = !_isSoundOn;
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sayaç Yazısı
          Text(
            "$_counter",
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0B973),
            ),
          ),
          const SizedBox(height: 30),

          // Büyük Buton
          ZikrButton(
            onTap: _incrementCounter,
          ),

          const SizedBox(height: 40),

          // Reset Butonu
          TextButton(
            onPressed: _resetCounter,
            child: const Text(
              "Reset",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZikrButton extends StatefulWidget {
  final VoidCallback onTap;

  const ZikrButton({super.key, required this.onTap});

  @override
  State<ZikrButton> createState() => _ZikrButtonState();
}

class _ZikrButtonState extends State<ZikrButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
      },
      child: AnimatedScale(
        scale: isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1C2541),
                Color(0xFF0B132B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isPressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x99E0B973),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}