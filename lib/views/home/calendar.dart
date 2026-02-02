import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/components/index/task_items.dart';
import 'package:doova/components/indicator.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:doova/views/task/edit_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _showCompleted = false;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false)
          .getInitialData(uid, context);
    });
    super.initState();
  }

  void _prevMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xff6F24E9);
    final bgColor = isDark ? Colors.black : Colors.white;
    final containerColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5);
    final toggleColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;

    // ✅ Build all days of the current month
    final lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = List.generate(
      lastDayOfMonth.day,
      (index) => DateTime(_selectedDate.year, _selectedDate.month, index + 1),
    );

    final provider = context.watch<TaskProvider>();

    // ✅ Use DateFormat to parse your custom string date
    final todayTasks = provider.tasks.where((task) {
      try {
        final taskDate = DateFormat('EEE, MMM d, y').parse(task.date);
        final onlyDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
        return isSameDate(onlyDate, _selectedDate);
      } catch (e) {
        debugPrint('❌ Could not parse task.date: ${task.date}');
        return false;
      }
    }).toList();

    final completedTasks = provider.completedTasks.where((task) {
      try {
        final taskDate = DateFormat('EEE, MMM d, y').parse(task.date);
        final onlyDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
        return isSameDate(onlyDate, _selectedDate);
      } catch (e) {
        debugPrint('❌ Could not parse task.date: ${task.date}');
        return false;
      }
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: size.width > 600
                ? topPadding +
                    size.height * 0.08 // Gives room for notch + your content
                : kToolbarHeight, // Use default on phones
            backgroundColor: bgColor,
            title: Text(
              'Calendar',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: size.width *0.06),
            ),
            centerTitle: true,
          ),
          body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            header: CustomHeader(
              height: size.height * 0.1,
              builder: (context, mode) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildCustomSpinner(context,size),
                  ),
                );
              },
            ),
            onRefresh: () async {
              await onRefresh(size: size);
            },
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: containerColor,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.015,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _prevMonth,
                              child: SizedBox(
                                height: size.height * 0.07,
                                width: size.width * 0.07,
                                child: Image.asset(
                                    fit: BoxFit.contain,
                                    IconManager.arrowStart,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    DateFormat('MMMM')
                                        .format(_selectedDate)
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: size.width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    DateFormat('y').format(_selectedDate),
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      fontSize: size.width * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _nextMonth,
                              child: SizedBox(
                                height: size.height * 0.07,
                                width: size.width * 0.07,
                                child: Image.asset(
                                    fit: BoxFit.contain,
                                    IconManager.arrowEnd,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),

                        // ✅ Month days horizontal scroll
                        SizedBox(
                          height: size.height * 0.1,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: daysInMonth.length,
                            itemBuilder: (context, index) {
                              final date = daysInMonth[index];
                              final isSelected =
                                  isSameDate(date, _selectedDate);
                              final isWeekend =
                                  date.weekday == DateTime.sunday ||
                                      date.weekday == DateTime.saturday;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  width: size.width * 0.13,
                                  margin:
                                       EdgeInsets.symmetric(horizontal: size.width*0.010),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark
                                            ? Colors.black
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.02),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E')
                                            .format(date)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : (isWeekend
                                                  ? Colors.red
                                                  : (isDark
                                                      ? Colors.white
                                                      : Colors.black)),
                                          fontSize: size.width * 0.03,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: size.height*0.010,),
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                          fontSize: size.width * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      child: Column(
                        children: [
                          // Toggle buttons
                          Container(
                            height: size.height * 0.1,
                            decoration: BoxDecoration(
                              color: toggleColor,
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.01),
                            ),
                            padding: EdgeInsets.all(size.width * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                rowButton(
                                  size: size,
                                  text: 'Today',
                                  isActive: !_showCompleted,
                                  onTap: () {
                                    setState(() {
                                      _showCompleted = false;
                                      _selectedDate = DateTime.now();
                                    });
                                  },
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                ),
                                rowButton(
                                  size: size,
                                  text: 'Completed',
                                  isActive: _showCompleted,
                                  onTap: () {
                                    setState(() {
                                      _showCompleted = true;
                                    });
                                  },
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),
                          // Tasks list
                          Expanded(
                            child: (_showCompleted
                                        ? completedTasks
                                        : todayTasks)
                                    .isEmpty
                                ? Center(
                                    child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          _showCompleted
                                              ? "No completed tasks for this date"
                                              : "No tasks for this date",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Color(0xff979797),fontSize: size.width*0.06)),
                                      SizedBox(
                                        height: size.height * 0.0030,
                                      ),
                                      Text(
                                          textAlign: TextAlign.center,
                                          _showCompleted
                                              ? "When you complete tasks for this date, they'll appear here"
                                              : "When you add tasks for this date, they'll appear here",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  color: Color(0xff979797),fontSize: size.width*0.04)),
                                    ],
                                  ))
                                : ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 80),
                                    itemCount: _showCompleted
                                        ? completedTasks.length
                                        : todayTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = _showCompleted
                                          ? completedTasks[index]
                                          : todayTasks[index];
                                      return _showCompleted
                                          ? CompletedTaskItems(
                                              size: size,
                                              completedTask: task,
                                              selectedCompletedTask: (tk) {
                                                final selectedTk =
                                                    completedTasks
                                                        .where((tk) =>
                                                            task.id == tk.id)
                                                        .toList();
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditTaskView(
                                                              task: selectedTk),
                                                    ));
                                              },
                                            )
                                          : TaskItems(
                                              size: size,
                                              task: task,
                                              selectedTask: (tk) {
                                                final selectedTk = todayTasks
                                                    .where((tk) =>
                                                        task.id == tk.id)
                                                    .toList();
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditTaskView(
                                                              task: selectedTk),
                                                    ));
                                              },
                                            );
                                    },
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
      },
    );
  }

  Widget rowButton({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
    required Size size,
  }) {
    return SizedBox(
      width: size.width * 0.4,
      height: size.height * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? primaryColor
              : (isDark ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.01),
            side: BorderSide(
              color: isActive ? primaryColor : const Color(0xff979797),
              width: size.width * 0.0030,
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.white : Colors.black),
            fontSize: size.width * 0.04,
          ),
        ),
      ),
    );
  }

  bool isSameDate(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return aDate == bDate;
  }

  Future<void> onRefresh({required Size size}) async {
  
    final isConnected = await hasNetwork();
    if (!isConnected) {
      if (!mounted) return;
      Toast.errorToast(
        isYellow: true,
        leading: SizedBox(
            height: size.height * 0.07,
            width: size.width * 0.07,
            child: Image.asset(
              IconManager.wifi,
              fit: BoxFit.contain,
              color: Colors.yellow,
            )),
        context,
        'No internet connection. Connect to the internet and try again',
        color: Colors.black.withOpacity(0.5),
        position: DelightSnackbarPosition.bottom,
      );
      _refreshController.refreshFailed();
      return;
    }

    try {
      await Provider.of<TaskProvider>(context, listen: false)
          .getInitialData(uid, context);
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      if (mounted) {
        Toast.errorToast(
            isYellow: true,
            leading: SizedBox(
                height: size.height * 0.07,
                width: size.width * 0.07,
                child: Image.asset(
                  IconManager.wifi,
                  fit: BoxFit.contain,
                  color: Colors.yellow,
                )),
            context,
            "We ran into a problem. Please try again shortly",
            color: Colors.black.withOpacity(0.5),
            position: DelightSnackbarPosition.bottom);
      }
    }
  }
}
