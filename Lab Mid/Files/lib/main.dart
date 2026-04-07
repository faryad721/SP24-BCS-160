import 'package:flutter/material.dart';
import 'package:task/screens/task_flow_app.dart';
import 'package:task/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.instance.initialize();
  runApp(const TaskFlowApp());
}
