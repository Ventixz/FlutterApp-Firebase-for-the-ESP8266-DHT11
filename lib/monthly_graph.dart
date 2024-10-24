// lib/monthly_graph.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_database/firebase_database.dart';

class MonthlyGraph extends StatefulWidget {
  @override
  _MonthlyGraphState createState() => _MonthlyGraphState();
}

class _MonthlyGraphState extends State<MonthlyGraph> {
  List<ChartData> _temperatureData = [];
  List<ChartData> _humidityData = [];
  bool _dataFetched = false;

  final LinearGradient _commonGradient = LinearGradient(
    colors: [Colors.green, Colors.lightGreen.withOpacity(0.5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_dataFetched) return;

    for (int i = 1; i <= 12; i++) {
      String tempPath = 'dht11/${i}month/temperature';
      String humidityPath = 'dht11/${i}month/humidity';

      DatabaseReference tempRef = FirebaseDatabase.instance.ref().child(tempPath);
      DatabaseReference humidityRef = FirebaseDatabase.instance.ref().child(humidityPath);

      DataSnapshot tempSnapshot = await tempRef.get();
      DataSnapshot humiditySnapshot = await humidityRef.get();

      if (tempSnapshot.exists && humiditySnapshot.exists) {
        setState(() {
          _temperatureData.add(ChartData(month: i, value: double.parse(tempSnapshot.value.toString())));
          _humidityData.add(ChartData(month: i, value: double.parse(humiditySnapshot.value.toString())));
        });
      } else {
        setState(() {
          _temperatureData.add(ChartData(month: i, value: 0));
          _humidityData.add(ChartData(month: i, value: 0));
        });
      }
    }

    setState(() {
      _dataFetched = true;
    });
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: _commonGradient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: _buildGradientDecoration(),
        ),
        title: Text(
          'Monthly Graph',
          style: TextStyle(
            fontFamily: 'Nexa',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: _buildGradientDecoration(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat, color: Colors.red),
                        SizedBox(width: 4),
                        Text('Temperature'),
                      ],
                    ),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('Humidity'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SfCartesianChart(
                      primaryXAxis: NumericAxis(title: AxisTitle(text: 'Month')),
                      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                      series: <ChartSeries>[
                        LineSeries<ChartData, int>(
                          dataSource: _temperatureData,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) => data.value,
                          name: 'Temperature',
                        ),
                        LineSeries<ChartData, int>(
                          dataSource: _humidityData,
                          xValueMapper: (ChartData data, _) => data.month,
                          yValueMapper: (ChartData data, _) => data.value,
                          name: 'Humidity',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final int month;
  final double value;

  ChartData({required this.month, required this.value});
}