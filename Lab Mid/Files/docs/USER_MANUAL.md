# TaskFlow User Manual

## Overview
TaskFlow is a Flutter-based task manager with local SQLite storage, repeat rules, subtasks, progress tracking, and export features. It works fully offline and supports Android notifications.

## Main Screens
Tabs at the top:
- Today: Tasks due today.
- Upcoming: Tasks due after today.
- Completed: Finished tasks.
- Repeated: Tasks with repeat rules.

## Adding a Task
1. Tap **New Task**.
2. Fill in Title, Description, and Category.
3. Pick Due Date and Time.
4. Set Repeat to None, Daily, or Weekly.
5. Add subtasks if needed.
6. Tap **Save**.

## Editing or Deleting a Task
1. Tap the three-dot menu on a task card.
2. Choose **Edit** or **Delete**.
3. Delete shows a confirmation dialog.

## Completing a Task
Use the checkbox on the task card to mark complete. It moves to the Completed tab.

## Subtasks and Progress
Subtasks appear in the details sheet:
1. Tap a task card to open details.
2. Toggle subtasks.
3. Tap **Save progress**.
The progress bar updates based on completed subtasks.

## Repeating Tasks
Set Repeat:
- Daily: repeats every day.
- Weekly: select weekdays to repeat.
When a repeating task is completed, the next due date is generated automatically.

## Notifications
Notifications are scheduled for task due dates.
To change sound:
1. Tap the Settings icon.
2. Choose **Default**, **Chime**, or **Silent**.

## Exporting Tasks
1. Tap the Export icon.
2. Choose CSV or PDF.
3. Use the share sheet to save or send via email.

## Theme Customization
1. Tap the Settings icon.
2. Select Light or Dark mode.

## Troubleshooting
- If a task doesn't show in Today, check the due date/time and look in Upcoming.
- If notifications don’t fire, verify notification permissions on Android.
- If export fails, ensure storage permissions are allowed (if prompted by Android).
