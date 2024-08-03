import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'db_helper.dart';
import 'location_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Distance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final LocationController locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distance Tracker'),
      ),
      body: Center(
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Distance Covered:'),
            Text(
              '${locationController.totalDistance.value.toStringAsFixed(2)} meters',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ElevatedButton(
              onPressed: () async {
                await DBHelper.insert('distances', {
                  'id': DateTime.now().toIso8601String(),
                  'distance': locationController.totalDistance.value,
                });
              },
              child: Text('Save Distance'),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = await DBHelper.getData('distances');
                data.forEach((row) {
                  print('ID: ${row['id']}, Distance: ${row['distance']}');
                });
              },
              child: Text('Load Distances'),
            ),
          ],
        )),
      ),
    );
  }
}
