import 'dart:async';
import 'dart:convert';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/provider/focus/app_usage.dart';
import 'package:doova/r.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doova/constant/dummy.dart';
import 'package:doova/model/add_task/category.dart';
import 'package:doova/model/add_task/priority.dart';
import 'package:doova/model/add_task/sub_task.dart';
import 'package:doova/model/add_task/task.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final String catchMessage = 'We ran into a problem. Please try again shortly';
final String networkMessage =
    'No internet connection. Connect to the internet and try again';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TaskModel> _tasks = [];
  List<TaskModel> _completedTasks = [];
  final Map<String, List<SubTaskModel>> _subTasksMap = {};
  CategoryModel? selectedCategory;
  int? selectedPriority;
  String? selectedDate;
  TimeOfDay? _selectedTime;
  Timer? _autoCompleteTimer;
  bool _isLoading = false;
  bool _hasFetched = false;
  final Map<String, TextEditingController> _titleControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  List<TaskModel> get completedTasks => _completedTasks;
  List<TaskModel> get tasks => _tasks;
  TimeOfDay? get selectedTime => _selectedTime;
  final List<CategoryModel> _defaultCategories = categories;
  final List<CategoryModel> _userCategories = [];
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
  List<CategoryModel> get allCategories => [
        ..._userCategories,
        ..._defaultCategories,
      ];
  List<SubTaskModel> getSubTasks(String taskId) => _subTasksMap[taskId] ?? [];

  Future<void> loadUserCategories(String uid, BuildContext context) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .doc(uid)
          .collection('categories')
          .get();

      _userCategories.clear(); // Clear previous data to avoid duplication
      _userCategories.addAll(
        snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data(), id: doc.id)),
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    }
  }

  Future<bool> addCategory(
      CategoryModel newCategory, BuildContext context) async {
    setLoading(true);
    try {
      if (!await hasNetwork()) {
        Toast.errorToast(context, networkMessage,
            color: Colors.red, position: DelightSnackbarPosition.top);
        return false;
      }
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = await _firestore
          .collection('tasks')
          .doc(uid)
          .collection('categories')
          .add(newCategory.toMap());

      final savedCategory = newCategory.copyWith(id: docRef.id);
      _userCategories.insert(0, savedCategory);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding category: $e');
      }

      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteCategory(
      BuildContext context, CategoryModel category, Size size) async {
    if (!await hasNetwork()) {
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isDefault = _defaultCategories.any((c) => c.title == category.title);
    if (isDefault) {
      Toast.errorToast(context, 'Deleting this category is not allowed',
          color: Colors.grey.shade900,
          position: DelightSnackbarPosition.bottom,
          leading: SizedBox(
              height: size.height * 0.06,
              width: size.width * 0.06,
              child: Image.asset(fit: BoxFit.contain, IconManager.warning)));
      return;
    }
    try {
      setLoading(true);
      await _firestore
          .collection('tasks')
          .doc(uid)
          .collection('categories')
          .doc(category.id)
          .delete();
      _userCategories.removeWhere((c) => c.id == category.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting category: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
    } finally {
      setLoading(false);
    }
  }

  Future<void> createTask({
    required BuildContext context,
    required String title,
    required String description,
    required int priority,
    required CategoryModel category,
    required String time,
    required String date,
    required UserProvider userProvider,
  }) async {
    if (!await hasNetwork()) {
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }
    try {
      setLoading(true);
      final user = userProvider.user!;
      final docRef = await _firestore.collection('tasks').add({
        'userId': user.uid,
        'title': title,
        'description': description,
        'priority': priority,
        'category': category.toMap(),
        'time': time,
        'date': date,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
      });
      final taskId = docRef.id;
      await docRef.update({'taskId': taskId});
      // Deduct 1 coin for non-premium users
      if (!user.isPremium) {
        await userProvider.updateCoin(user.coins - 1);
      }
      context.pop();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating task: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateTask({
    required BuildContext context,
    required String taskId,
    required String title,
    required String description,
    required int priority,
    required CategoryModel category,
    required String time,
    required String date,
  }) async {
    setLoading(true);
    if (!await hasNetwork()) {
      setLoading(false);
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
        'priority': priority,
        'category': category.toMap(),
        'time': time,
        'date': date,
        'taskId': taskId,
        'isCompleted': false,
        'updatedAt': Timestamp.now(),
      });
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating task: $e');
      }

      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteTask({
    required BuildContext context,
    required String taskId,
  }) async {
    setLoading(true);
    if (!await hasNetwork()) {
      setLoading(false);
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return;
    }
    try {
      // 1️⃣ Get all subtasks for this task
      final subTasksSnapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .get();
      // 2️⃣ Create a batch to delete everything atomically
      final batch = _firestore.batch();
      // 3️⃣ Add each subtask to the batch for deletion
      for (final doc in subTasksSnapshot.docs) {
        batch.delete(doc.reference);
      }
      // 4️⃣ Add the parent task to the batch
      batch.delete(_firestore.collection('tasks').doc(taskId));
      // 5️⃣ Commit the batch
      await batch.commit();
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting task and subtasks: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
    } finally {
      setLoading(false);
    }
  }

  void fetchTasks(String uid) {
    if (!_hasFetched) {
      _hasFetched = true;
      setLoading(true);
    }

    _firestore
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final allTasks = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();

      _tasks = allTasks.where((t) => !t.isCompleted).toList();
      _completedTasks = allTasks.where((t) => t.isCompleted).toList();

      if (_isLoading) setLoading(false);
      notifyListeners();
    }, onError: (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
      setLoading(false);
    });
  }

  void startAutoCompleteChecker(String uid, bool isFocusModeOn) {
    _autoCompleteTimer?.cancel();

    _autoCompleteTimer =
        Timer.periodic(const Duration(seconds: 5), (_) async {
      if (kDebugMode) {
        debugPrint('⏰ Auto-complete check running...');
      }
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .where('isCompleted', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      List<TaskModel> tasksToNotify = [];

      for (var doc in snapshot.docs) {
        final task = TaskModel.fromMap(doc.data(), doc.id);
        final taskDate = DateFormat('EEE, MMM d, y').parse(task.date);
        final parsedTime = DateFormat.jm().parse(task.time);

        final taskDateTime = DateTime(
          taskDate.year,
          taskDate.month,
          taskDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        if (now.isAfter(taskDateTime)) {
          if (task.isRepeating) {
            // Only send notification ONCE per day, then update the date to next day
            final nextDate = taskDate.add(const Duration(days: 1));
            final taskRef = _firestore.collection('tasks').doc(task.taskId);
            batch.update(taskRef, {
              'date': DateFormat('EEE, MMM d, y').format(nextDate),
              'isCompleted': false,
              'updatedAt': Timestamp.now(),
            });
            tasksToNotify.add(task);
          } else {
               if (kDebugMode){
                  debugPrint('✅ Marking task ${task.taskId} as complete...');
               }
          
            final taskRef = _firestore.collection('tasks').doc(task.taskId);
            batch.update(taskRef, {
              'isCompleted': true,
              'updatedAt': Timestamp.now(),
            });
            tasksToNotify.add(task);
          }
        }
      }

      if (tasksToNotify.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('💾 Committing batch...');
        }

        await batch.commit();

        if (!isFocusModeOn) {
          for (final task in tasksToNotify) {
               if (kDebugMode){
                 debugPrint('🚀 Sending push for task: ${task.title}');
               } 
            await sendPushRequestToBackend(
              uid,
              task.title,
              task.date,
              task.time,
              task.taskId,
            );
          }
        } else {
          if (kDebugMode) {
            debugPrint('🔇 Focus Mode ON — push skipped, tasks updated.');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('📭 No tasks to auto-complete this cycle.');
        }
      }

      fetchTasks(uid);
    });
  }

  Future<void> sendPushRequestToBackend(String uid, String taskTitle,
      String date, String time, String taskId) async {
    try {
      final url = Uri.parse(
        'https://us-central1-doova-709a7.cloudfunctions.net/sendPush',
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': uid,
              'taskTitle': taskTitle,
              'taskDate': date, // ✅ FIXED: Send raw date
              'taskTime': time, // ✅ FIXED: Send raw time
              'taskId': taskId,
            }),
          )
          .timeout(const Duration(seconds: 10));
         if (kDebugMode) {
           debugPrint(
          '📲 Backend push response: ${response.statusCode} ${response.body}');
         }
     

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('⚠️ Push failed with status: ${response.statusCode}');
        }
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        debugPrint('⏰ Push request timed out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending push request: $e');
      }
    }
  }

  Future<void> saveFcmToken(String uid) async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': token});
  }

  Future<bool> toggleRepeat(
    String taskId,
    bool newValue,
    BuildContext context,
  ) async {
    setLoading(true);

    if (!await hasNetwork()) {
      setLoading(false);
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false; // ❌ failed
    }

    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isRepeating': newValue,
        'updatedAt': Timestamp.now(),
      });
      notifyListeners();
      return true; // ✅ success
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error toggling repeat: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    } finally {
      setLoading(false);
    }
  }

  List<TaskModel> searchTasks(String query) {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) return [];
    return _tasks
        .where((task) =>
            !task.isCompleted && // ✅ Ensures only active tasks
            (task.title.toLowerCase().contains(lowerQuery) ||
                task.description.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  // ✅ Firestore Recent Searches
  Future<List<String>> getRecentSearches(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return [];
    final list = List<String>.from(data['recent_searches'] ?? []);
    return list;
  }

  Future<void> saveRecentSearch(String uid, String query) async {
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();

    List<String> updatedList = [];

    if (snapshot.exists) {
      final data = snapshot.data();
      final List<dynamic> existing = data?['recent_searches'] ?? [];
      updatedList = List<String>.from(existing);
    }

    if (!updatedList.contains(query)) {
      updatedList.insert(0, query);
      if (updatedList.length > 10) {
        updatedList = updatedList.sublist(0, 10);
      }
    }

    await docRef.set({'recent_searches': updatedList}, SetOptions(merge: true));
  }

  Future<void> clearAllRecentSearches(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    await docRef.set({'recent_searches': []}, SetOptions(merge: true));
  }

  Future<void> fetchSubTasks(String taskId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .orderBy('title')
          .get();

      final subTasks = snapshot.docs
          .map((doc) => SubTaskModel.fromMap(doc.data(), doc.id))
          .toList();

      _subTasksMap[taskId] = subTasks;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching subtasks: $e');
      }
    }
  }

  Future<bool> addSubTask(
    String taskId,
    SubTaskModel subTask,
    BuildContext context,
  ) async {
    setLoading(true); // start loading *before* network check

    if (!await hasNetwork()) {
      setLoading(false); // stop loading before returning
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    }

    try {
      final docRef = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .add(subTask.toMap());

      final newSubTask = subTask.copyWith(id: docRef.id);
      _subTasksMap[taskId] = [...getSubTasks(taskId), newSubTask];
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding subtask: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    } finally {
      setLoading(false); // always stop loading
    }
  }

  Future<bool> updateSubTask(
    String taskId,
    SubTaskModel subTask,
    BuildContext context,
  ) async {
    setLoading(true);

    if (!await hasNetwork()) {
      setLoading(false);
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    }

    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subTask.id)
          .update(subTask.toMap());

      final subTasks = getSubTasks(taskId).map((st) {
        if (st.id == subTask.id) return subTask;
        return st;
      }).toList();

      _subTasksMap[taskId] = subTasks;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating subtask: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteSubTask(
    String taskId,
    String subTaskId,
    BuildContext context,
  ) async {
    setLoading(true);

    if (!await hasNetwork()) {
      setLoading(false);
      Toast.errorToast(context, networkMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    }

    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('subtasks')
          .doc(subTaskId)
          .delete();

      _subTasksMap[taskId] =
          getSubTasks(taskId).where((st) => st.id != subTaskId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting subtask: $e');
      }
      Toast.errorToast(context, catchMessage,
          color: Colors.red, position: DelightSnackbarPosition.top);
      return false;
    } finally {
      setLoading(false);
    }
  }

  setSelectedCategory(CategoryModel selectedCate) {
    selectedCategory = selectedCate;
    notifyListeners();
  }

  List<CategoryModel> get categoryFallback {
    final copiedList = List.of(categories); // Create a copy
    final filteredCategory = copiedList.where((ct) {
      return ct.title.trim().toLowerCase() != 'create new';
    }).toList();
    filteredCategory.shuffle();
    return filteredCategory;
  }

  setSelectedPriority(int onSelectedPriority) {
    selectedPriority = onSelectedPriority;
    notifyListeners();
  }

  List<PriorityModel> get priorityFallback {
    final newPriority = List.of(priority);
    newPriority.shuffle();
    return newPriority;
  }

  void getSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    notifyListeners();
  }

  String get formattedSelectedTime {
    if (_selectedTime == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour,
        _selectedTime!.minute);
    return DateFormat.jm().format(dt);
  }

  getSelectedDate(DateTime date) {
    selectedDate = DateFormat('EEE, MMM d, y').format(date);
    notifyListeners();
  }

  String formatEditTaskDateTime({
    required String dateString,
    required String timeString,
  }) {
    try {
      final parsedDate = DateFormat('EEE, MMM d, y').parse(dateString);
      final today = DateTime.now();
      final isToday = parsedDate.year == today.year &&
          parsedDate.month == today.month &&
          parsedDate.day == today.day;

      final dayLabel =
          isToday ? 'Today' : DateFormat('EEEE').format(parsedDate);
      return '$dayLabel at $timeString';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error formatting date: $e');
      }

      return '$dateString at $timeString';
    }
  }

  TimeOfDay parseTime(String timeStr) {
    try {
      final format = DateFormat.jm();
      final dt = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dt);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  TextEditingController getTitleController(String taskId, String defaultText) {
    return _titleControllers.putIfAbsent(taskId, () {
      return TextEditingController(text: defaultText);
    });
  }

  TextEditingController getDescriptionController(
      String taskId, String defaultText) {
    return _descriptionControllers.putIfAbsent(taskId, () {
      return TextEditingController(text: defaultText);
    });
  }

  void clearControllers(String taskId) {
    _titleControllers[taskId]?.dispose();
    _descriptionControllers[taskId]?.dispose();
    _titleControllers.remove(taskId);
    _descriptionControllers.remove(taskId);
  }

  @override
  void dispose() {
    for (final c in _titleControllers.values) {
      c.dispose();
    }
    for (final c in _descriptionControllers.values) {
      c.dispose();
    }
    _autoCompleteTimer?.cancel();
    super.dispose();
  }

  getInitialData(String uid, BuildContext context) async {
    try {
      fetchTasks(
        uid,
      );
      bool isFocusing = context.read<FocusModeProvider>().isFocusing;
      startAutoCompleteChecker(uid, isFocusing);
      await loadUserCategories(uid, context);
    } catch (e) {
      if (kDebugMode) print('Error initializing data: $e');
    }
    notifyListeners();
  }
}
