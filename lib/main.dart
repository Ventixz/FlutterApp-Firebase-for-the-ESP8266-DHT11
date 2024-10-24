import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'live_graph.dart';
import 'monthly_graph.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: '',
      appId: '1:1008412615090:android:e08e6c39c19103af61c4ab',
      messagingSenderId: '1008412615090',
      projectId: 'arduino-dht11-44e1c',
      databaseURL: 'https://arduino-dht11-44e1c-default-rtdb.asia-southeast1.firebasedatabase.app/',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charcoal Cooling System Monitor',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Charcoal Cooling System Monitor'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String currentView = 'current';
  String selectedTimeline = 'current';
  bool isGaugeExpanded = false;
  bool isGraphExpanded = false;
  File? _profileImage;
  String _username = 'Username';
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUsername();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      _saveProfileImage(image.path);
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path);
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null) {
      setState(() {
        _username = username;
        _usernameController.text = username;
      });
    }
  }

  Map<String, Color> _getButtonColors(String view) {
    return currentView == view
        ? {'background': Colors.blue, 'text': Colors.white}
        : {'background': Colors.white, 'text': Colors.black};
  }

  Widget buildStreamBuilder(String tempPath, String humidityPath, String label, IconData tempIcon, IconData humidityIcon) {
    return SensorDisplayCard(tempPath: tempPath, humidityPath: humidityPath, label: label, tempIcon: tempIcon, humidityIcon: humidityIcon);
  }

  void _onMenuSelected(String value) {
    setState(() {
      if (value == 'Gauge') {
        isGaugeExpanded = !isGaugeExpanded;
      } else if (value == 'Graph') {
        isGraphExpanded = !isGraphExpanded; // Handle new dropdown
      } else {
        currentView = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: widget.title),
      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/profile.png'),
                    ),
                  ),
                  SizedBox(height: 8), // Add spacing between the avatar and the username
                  TextField(
                    controller: _usernameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nexa',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _username = value;
                      });
                      _saveUsername(value);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Gauge'),
              tileColor: currentView == 'Gauge' ? Colors.blue : Colors.white,
              textColor: currentView == 'Gauge' ? Colors.white : Colors.black,
              onTap: () => _onMenuSelected('Gauge'),
            ),
            if (isGaugeExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: <String>['current', '30 minutes', '1 day', '3 days', '7 days', '1 month', '3 months']
                      .map((String value) {
                    return ListTile(
                      title: Text(value),
                      tileColor: currentView == value ? Colors.blue : Colors.white,
                      textColor: currentView == value ? Colors.white : Colors.black,
                      onTap: () => _onMenuSelected(value),
                    );
                  }).toList(),
              ),
            ),
            ListTile(
              title: Text('Graph'),
              tileColor: currentView == 'Graph' ? Colors.blue : Colors.white,
              textColor: currentView == 'Graph' ? Colors.white : Colors.black,
              onTap: () => _onMenuSelected('Graph'),
            ),
            if (isGraphExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Monthly Graph'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MonthlyGraph()),
                        );
                      },
                    ),
                    ListTile(
                      title: Text('Live Graph'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LiveGraph()),
                        );
                      },
                    ),
                  ],
                ),
              ),            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Fake logout action
                  },
                  child: Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen.withOpacity(0.5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (currentView == 'current')
                      buildStreamBuilder('dht11/current/temperature', 'dht11/current/humidity', 'Current Readings', Icons.thermostat, Icons.water_drop)
                    else if (currentView == '30 minutes')
                      buildStreamBuilder('dht11/30min/temperature', 'dht11/30min/humidity', '30 Minutes Readings', Icons.thermostat, Icons.water_drop)
                    else if (currentView == '1 day')
                        buildStreamBuilder('dht11/1day/temperature', 'dht11/1day/humidity', '1 Day Readings', Icons.thermostat, Icons.water_drop)
                      else if (currentView == '3 days')
                          buildStreamBuilder('dht11/3days/temperature', 'dht11/3days/humidity', '3 Days Readings', Icons.thermostat, Icons.water_drop)
                        else if (currentView == '7 days')
                            buildStreamBuilder('dht11/7days/temperature', 'dht11/7days/humidity', '7 Days Readings', Icons.thermostat, Icons.water_drop)
                          else if (currentView == '1 month')
                              buildStreamBuilder('dht11/1month/temperature', 'dht11/1month/humidity', '1 Month Readings', Icons.thermostat, Icons.water_drop)
                            else if (currentView == '3 months')
                                buildStreamBuilder('dht11/3month/temperature', 'dht11/3month/humidity', '3 Months Readings', Icons.thermostat, Icons.water_drop)
                              else if (currentView == 'Gauge')
                                  buildStreamBuilder('dht11/current/temperature', 'dht11/current/humidity', 'Current Readings', Icons.thermostat, Icons.water_drop)
                  ],
                ),
              ),
            ),
            Container(
              height: 50, // Fixed height to avoid overflow issues
              padding: const EdgeInsets.only(bottom: 4.0), // Add padding to avoid pixel overflow
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = 'current'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('current')['background'],
                      ),
                      child: Text(
                        'Current',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('current')['text'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = '30 minutes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('30 minutes')['background'],
                      ),
                      child: Text(
                        '30 Minutes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('30 minutes')['text'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = '1 day'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('1 day')['background'],
                      ),
                      child: Text(
                        '1 Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('1 day')['text'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = '3 days'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('3 days')['background'],
                      ),
                      child: Text(
                        '3 Days',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('3 days')['text'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = '7 days'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('7 days')['background'],
                      ),
                      child: Text(
                        '7 Days',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('7 days')['text'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = '1 month'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('1 month')['background'],
                      ),
                      child: Text(
                        '1 Month',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('1 month')['text'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing
                    ElevatedButton(
                      onPressed: () => setState(() => currentView = '3 months'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColors('3 months')['background'],
                      ),
                      child: Text(
                        '3 Months',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getButtonColors('3 months')['text'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double barHeight = 56.0;

  GradientAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.lightGreen.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Nexa',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black45,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(barHeight);
}

class SensorDisplayCard extends StatelessWidget {
  final String tempPath;
  final String humidityPath;
  final String label;
  final IconData tempIcon;
  final IconData humidityIcon;

  const SensorDisplayCard({
    Key? key,
    required this.tempPath,
    required this.humidityPath,
    required this.label,
    required this.tempIcon,
    required this.humidityIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        color: Colors.green.withOpacity(0.1),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              StreamBuilder(
                stream: FirebaseDatabase.instance.ref().child(tempPath).onValue,
                builder: (context, tempSnapshot) {
                  if (tempSnapshot.hasData && !tempSnapshot.hasError && tempSnapshot.data!.snapshot.value != null) {
                    double temperature = double.parse(tempSnapshot.data!.snapshot.value.toString());
                    return SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          ranges: <GaugeRange>[
                            GaugeRange(startValue: 0, endValue: 30, color: Colors.lightBlueAccent),
                            GaugeRange(startValue: 30, endValue: 60, color: Colors.green),
                            GaugeRange(startValue: 60, endValue: 100, color: Colors.red),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: temperature),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                'Temperature: $temperature°C',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return const Text('Loading temperature...');
                  }
                },
              ),
              StreamBuilder(
                stream: FirebaseDatabase.instance.ref().child(humidityPath).onValue,
                builder: (context, humiditySnapshot) {
                  if (humiditySnapshot.hasData && !humiditySnapshot.hasError && humiditySnapshot.data!.snapshot.value != null) {
                    double humidity = double.parse(humiditySnapshot.data!.snapshot.value.toString());
                    return SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          ranges: <GaugeRange>[
                            GaugeRange(startValue: 0, endValue: 30, color: Colors.lightBlueAccent),
                            GaugeRange(startValue: 30, endValue: 60, color: Colors.lightBlue),
                            GaugeRange(startValue: 60, endValue: 100, color: Colors.blue),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(value: humidity),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                'Humidity: $humidity%',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              angle: 90,
                              positionFactor: 0.5,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return const Text('Loading humidity...');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}