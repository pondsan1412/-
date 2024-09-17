import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const FlashlightApp());
}

// หน้าหลัก (หน้าไฟฉาย)
class FlashlightApp extends StatelessWidget {
  const FlashlightApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.amber,
      ),
      home: const FlashlightHomePage(),
    );
  }
}

class FlashlightHomePage extends StatefulWidget {
  const FlashlightHomePage({Key? key}) : super(key: key);

  @override
  _FlashlightHomePageState createState() => _FlashlightHomePageState();
}

class _FlashlightHomePageState extends State<FlashlightHomePage> {
  bool _isTorchOn = false;
  Timer? _strobeTimer;
  int? _strobeFrequency;  // กำหนดค่าเริ่มต้นเป็น null
  bool _isEnglish = false; // ตัวแปรเก็บสถานะภาษา

  Future<void> _toggleTorch() async {
    try {
      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // ฟังก์ชันสำหรับกระพริบไฟฉาย
  void _flashStrobe(int frequency) {
    if (_strobeTimer != null) {
      _strobeTimer?.cancel();
    }

    _strobeTimer = Timer.periodic(Duration(milliseconds: (1000 / frequency).round()), (timer) async {
      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    });
  }

  // หยุดการกระพริบไฟฉาย
  void _stopStrobe() {
    _strobeTimer?.cancel();
    setState(() {
      _isTorchOn = false;
    });
    TorchLight.disableTorch();
  }

  @override
  void dispose() {
    _strobeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEnglish ? 'Flashlight App' : 'ไฟฉายแบบตึงๆ'),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language), // ไอคอนสลับภาษา
            onPressed: () {
              setState(() {
                _isEnglish = !_isEnglish; // สลับค่าภาษา
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutMePage(isEnglish: _isEnglish)),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              key: const Key('toggle_torch'), // เพิ่ม Key สำหรับการทดสอบ
              onTap: _toggleTorch,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isTorchOn ? Colors.amber : Colors.grey[800],
                  boxShadow: [
                    if (_isTorchOn)
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.7),
                        spreadRadius: 15,
                        blurRadius: 30,
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: _isTorchOn ? Colors.black : Colors.amber,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isEnglish ? 'Choose Strobe Frequency (Times per second):' : 'แตะที่ปุ่มเพื่อเปิดไฟฉาย\nเพื่อเปิดไฟฉายค้างเอาไว้',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButton<int>(
            hint: Text(
              _isEnglish ? 'Please select a frequency' : 'โปรดเลือกจำนวนครั้งที่กระพริบ', // ข้อความเริ่มต้น
            ),
            value: _strobeFrequency, // ใช้ค่า _strobeFrequency
            items: [1, 2, 3, 4, 5].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(_isEnglish ? '$value times/second' : '$value ครั้ง/วินาที'),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _strobeFrequency = newValue; // ตั้งค่าที่เลือกใหม่
              });
              if (newValue != null) {
                _flashStrobe(newValue);
              }
            },
            style: const TextStyle(color: Colors.amber),
            dropdownColor: Colors.grey[800],
            iconEnabledColor: Colors.amber,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _stopStrobe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(_isEnglish ? 'Stop Strobe' : 'หยุดกระพริบ'),
          ),
        ],
      ),
    );
  }
}

// หน้า About Me
class AboutMePage extends StatelessWidget {
  final bool isEnglish;

  const AboutMePage({Key? key, required this.isEnglish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'About Me' : 'เกี่ยวกับฉัน'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'Bio' : 'ชีวะประวัติ',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isEnglish
                  ? 'Present: Working as a back-end developer at Mass Corporation Co., Ltd.'
                  : 'ปัจจุบัน: ทำงานในตำแหน่ง นักพัฒนาโปรแกรมส่วนหลังบ้าน ที่บริษัท แมสคอร์ปอร์เรชั่น',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              isEnglish ? 'Technologies' : 'เทคโนโลยี',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: 'dart',
              items: <String>[
                'Python',
                'Javascript',
                'React.js',
                'Next.js',
                'Node.js',
                'Flutter',
                'vscode',
                'android studio',
                'html',
                'firebase',
                'mysql',
                'phpmyadmin',
                'dart',
                'cython',
                'discord.py',
                'discord.js',
                'framer motion',
                'Chakra UI',
                'Three.js'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                // ปรับการทำงานตามค่าที่เลือก
              },
              style: const TextStyle(color: Colors.amber, fontSize: 16),
              dropdownColor: Colors.grey[800],
              iconEnabledColor: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              isEnglish ? 'Social' : 'โซเชียล',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SocialLinkCard(
              icon: Icons.code,
              label: 'GitHub',
              url: 'https://github.com/pondsan1412',
            ),
            SocialLinkCard(
              icon: Icons.link,
              label: 'Twitter',
              url: 'https://twitter.com/Pondmk1412',
            ),
            SocialLinkCard(
              icon: Icons.person,
              label: 'Facebook',
              url: 'https://www.facebook.com/pondcomp',
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child: Text(
                  isEnglish ? '🏠 Home' : '🏠 หน้าหลัก',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
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
}

// Widget สำหรับแสดง Social Link
class SocialLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const SocialLinkCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber),
        title: Text(label),
        onTap: () {
          _launchURL(url);
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
