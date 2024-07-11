import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCg5gpOk4WjIsnw5CoFeWzbCliPGa2D0A',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  Widget buildStreamBuilder(String tempPath, String humidityPath, String label, IconData tempIcon, IconData humidityIcon) {
    return SensorDisplayCard(tempPath: tempPath, humidityPath: humidityPath, label: label, tempIcon: tempIcon, humidityIcon: humidityIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildStreamBuilder('dht11/current/temperature', 'dht11/current/humidity', 'Current Readings', Icons.thermostat, Icons.water_drop),
              buildStreamBuilder('dht11/30min/temperature', 'dht11/30min/humidity', '30 Minutes Readings', Icons.thermostat, Icons.water_drop),
              buildStreamBuilder('dht11/1day/temperature', 'dht11/1day/humidity', '1 Day Readings', Icons.thermostat, Icons.water_drop),
              buildStreamBuilder('dht11/3days/temperature', 'dht11/3days/humidity', '3 Days Readings', Icons.thermostat, Icons.water_drop),
              buildStreamBuilder('dht11/7days/temperature', 'dht11/7days/humidity', '7 Days Readings', Icons.thermostat, Icons.water_drop),
              buildStreamBuilder('dht11/1month/temperature', 'dht11/1month/humidity', '1 Month Readings', Icons.thermostat, Icons.water_drop),
              buildStreamBuilder('dht11/3months/temperature', 'dht11/3months/humidity', '3 Months Readings', Icons.thermostat, Icons.water_drop),
            ],
          ),
        ),
      ),
    );
  }
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
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleLarge),
            StreamBuilder(
              stream: FirebaseDatabase.instance.ref().child(tempPath).onValue,
              builder: (context, tempSnapshot) {
                if (tempSnapshot.hasData && !tempSnapshot.hasError && tempSnapshot.data!.snapshot.value != null) {
                  return Row(
                    children: [
                      Icon(tempIcon, size: 24),
                      SizedBox(width: 8),
                      Text('Temperature: ${tempSnapshot.data!.snapshot.value}',
                          style: Theme.of(context).textTheme.headlineMedium),
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
                  return Row(
                    children: [
                      Icon(humidityIcon, size: 24),
                      SizedBox(width: 8),
                      Text('Humidity: ${humiditySnapshot.data!.snapshot.value}',
                          style: Theme.of(context).textTheme.headlineMedium),
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
    );
  }
}