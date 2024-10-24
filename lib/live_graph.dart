import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'custom_drawer.dart'; // Import the new CustomDrawer widget

class LiveGraph extends StatefulWidget {
  @override
  _LiveGraphState createState() => _LiveGraphState();
}

class _LiveGraphState extends State<LiveGraph> {
  List<LiveData> chartData = [];
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    FirebaseDatabase.instance.ref().child('dht11/current').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final double temperature = double.parse(data['temperature'].toString());
      final double humidity = double.parse(data['humidity'].toString());
      setState(() {
        chartData.add(LiveData(DateTime.now(), temperature, humidity));
        if (chartData.length > 20) {
          chartData.removeAt(0);
        }
        _chartSeriesController.updateDataSource(
          addedDataIndex: chartData.length - 1,
          removedDataIndex: 0,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Live Graph'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen.withOpacity(0.5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thermostat, color: Colors.red),
                    SizedBox(width: 4),
                    Text('Temperature', style: TextStyle(color: Colors.red)),
                    SizedBox(width: 16),
                    Icon(Icons.water_drop, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('Humidity', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // Adjust the width
                  height: MediaQuery.of(context).size.height * 0.4, // Adjust the height
                  color: Colors.green.withOpacity(0.1),
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <LineSeries<LiveData, DateTime>>[
                      LineSeries<LiveData, DateTime>(
                        onRendererCreated: (ChartSeriesController controller) {
                          _chartSeriesController = controller;
                        },
                        dataSource: chartData,
                        xValueMapper: (LiveData data, _) => data.time,
                        yValueMapper: (LiveData data, _) => data.temperature,
                        name: 'Temperature',
                        color: Colors.red, // Swapped color
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                        ),
                      ),
                      LineSeries<LiveData, DateTime>(
                        dataSource: chartData,
                        xValueMapper: (LiveData data, _) => data.time,
                        yValueMapper: (LiveData data, _) => data.humidity,
                        name: 'Humidity',
                        color: Colors.blue, // Swapped color
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.diamond,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiveData {
  LiveData(this.time, this.temperature, this.humidity);
  final DateTime time;
  final double temperature;
  final double humidity;
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(barHeight);
}