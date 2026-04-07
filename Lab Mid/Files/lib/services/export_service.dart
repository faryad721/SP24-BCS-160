import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:task/models/task_bundle.dart';

class ExportService {
  Future<File> exportCsv(List<TaskBundle> bundles) async {
    final rows = <List<String>>[
      [
        'Title',
        'Description',
        'Category',
        'Due Date',
        'Completed',
        'Repeat',
        'Subtasks'
      ],
    ];
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    for (final bundle in bundles) {
      final subtaskTitles = bundle.subtasks.map((s) {
        final status = s.isCompleted ? 'done' : 'pending';
        return '${s.title} [$status]';
      }).join(' | ');
      rows.add([
        bundle.task.title,
        bundle.task.description,
        bundle.task.category,
        formatter.format(bundle.task.dueDate),
        bundle.task.isCompleted ? 'Yes' : 'No',
        bundle.task.repeatType.name,
        subtaskTitles,
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final file = await _createExportFile('tasks.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<File> exportPdf(List<TaskBundle> bundles) async {
    final doc = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Task Export',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Title', 'Category', 'Due', 'Completed', 'Repeat'],
            data: bundles.map((bundle) {
              return [
                bundle.task.title,
                bundle.task.category,
                formatter.format(bundle.task.dueDate),
                bundle.task.isCompleted ? 'Yes' : 'No',
                bundle.task.repeatType.name,
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Details'),
          pw.SizedBox(height: 8),
          ...bundles.map((bundle) {
            final subtasks = bundle.subtasks.isEmpty
                ? 'No subtasks'
                : bundle.subtasks
                    .map((s) =>
                        '- ${s.title} (${s.isCompleted ? 'done' : 'pending'})')
                    .join('\n');
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    bundle.task.title,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(bundle.task.description),
                  if (bundle.task.category.isNotEmpty)
                    pw.Text('Category: ${bundle.task.category}'),
                  pw.Text('Due: ${formatter.format(bundle.task.dueDate)}'),
                  pw.Text('Subtasks:\n$subtasks'),
                ],
              ),
            );
          }),
        ],
      ),
    );

    final file = await _createExportFile('tasks.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> _createExportFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, name));
  }
}
