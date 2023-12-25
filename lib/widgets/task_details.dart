import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_model/utils/extensions.dart';

import '../config/routes/routes_location.dart';
import '../data/models/task.dart';
import '../providers/category_provider.dart';
import '../providers/date_provider.dart';
import '../providers/time_provider.dart';
import '../providers/task/tasks_provider.dart';
import '../utils/app_alerts.dart';
import '../utils/helpers.dart';
import 'circle_container.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.note);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme
        .of(context)
        .textTheme;

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleContainer(
            color: widget.task.category.color.withOpacity(0.3),
            child: Icon(
              widget.task.category.icon,
              color: widget.task.category.color,
            ),
          ),
          const Gap(16),
          _isEditing
              ? TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
            ),
          )
              : Text(
            widget.task.title,
            style: style.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(widget.task.time, style: style.titleMedium),
          const Gap(16),
          Visibility(
            visible: !_isEditing && !widget.task.isCompleted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Task to be completed on '),
                Text(widget.task.date),
                Icon(
                  Icons.check_box,
                  color: widget.task.category.color,
                ),
              ],
            ),
          ),
          const Gap(16),
          Divider(
            color: widget.task.category.color,
            thickness: 1.5,
          ),
          const Gap(16),
          _isEditing
              ? TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Note',
            ),
          )
              : Text(
            widget.task.note.isEmpty
                ? 'There is no additional note for this task'
                : widget.task.note,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Visibility(
            visible: !_isEditing && !widget.task.isCompleted,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: Text('Edit'),
            ),
          ),
          Visibility(
            visible: !_isEditing && widget.task.isCompleted,
            child: const Text('Completed Task Cannot be Edited'),
          ),
          const Gap(16),
          Visibility(
            visible: !_isEditing && widget.task.isCompleted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Task Completed'),
                Icon(
                  Icons.check_box,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          const Gap(16),
          Visibility(
            visible: _isEditing && !widget.task.isCompleted,
            child: ElevatedButton(
              onPressed: () {
                // _updateTask;
                _updateTask;
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTask(ProviderRef ref) async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final time = ref.read(timeProvider);
    final date = ref.read(dateProvider);
    final category = ref.read(categoryProvider);

    if (title.isNotEmpty) {
      final updatedTask = widget.task.copyWith(
        title: title,
        category: category,
        time: Helpers.timeToString(time),
        date: DateFormat.yMMMd().format(date),
        note: note,
      );

      await ref.read(tasksProvider.notifier).updateTask(updatedTask).then((value) {
        AppAlerts.displaySnackbar(context, 'Task updated successfully');
        Future.delayed(const Duration(milliseconds: 300), () {
          // Refresh the list of tasks to reflect the update
          ref.read(tasksProvider.notifier).getTasks();
          Navigator.pop(context); // Navigate back to the previous screen
        });
      }).catchError((error) {
        AppAlerts.displaySnackbar(context, 'Failed to update task: $error');
      });
    } else {
      AppAlerts.displaySnackbar(context, 'Title cannot be empty');
    }
  }
}
