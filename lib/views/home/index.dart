import 'dart:async';

import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/components/index/task_items.dart';
import 'package:doova/components/indicator.dart';
import 'package:doova/components/profile/user_profile_image.dart';
import 'package:doova/provider/focus/app_usage.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/modal_helper.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:doova/views/task/edit_task.dart';
import 'package:doova/views/task/search_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key, this.showcaseKeys = const []});
  final List<GlobalKey> showcaseKeys;

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  final RefreshController _refreshController = RefreshController();
  late UserProvider userProvider;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUser(uid);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getInitialData();
    });
    super.initState();
  }

  getInitialData() {
    if (!mounted) return;
    Provider.of<TaskProvider>(context, listen: false)
        .getInitialData(uid, context);
    Provider.of<TaskProvider>(context, listen: false).saveFcmToken(uid);
    //FOR FOCUS SCREEN
    final provider = context.read<FocusModeProvider>();
    provider.checkPermission();
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    provider.fetchUsageStats(start: startToday, end: now);
    provider.fetchDailyFocusHours();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      checkUserExistence(user);
    });
  }

  checkUserExistence(User? user) {
    if (user != null) {
      context.read<FocusModeProvider>().fetchDailyFocusHours();
    } else {
      context.read<FocusModeProvider>().resetFocusForCurrentUser();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final topPadding = MediaQuery.of(context).padding.top;
        final isLargeScreen = size.width > 600;
        final avatarSize = size.width * 0.18; // 20% of screen width
        double radius = size.width > 600
            ? size.width * 0.05 // Tablet/Fold
            : size.width * 0.06; // Phone
        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: SizedBox(
            height: isLargeScreen ? 72 : 56, // ⬅️ larger on tablet
            width: isLargeScreen ? 72 : 56,
            child: FloatingActionButton(
                shape: ShapeBorder.lerp(const CircleBorder(),
                    const CircleBorder(), BorderSide.strokeAlignInside),
                backgroundColor: Color(0xff6F24E9),
                onPressed: () {
                  openModalBottomSheet(context, size);
                },
                child: Icon(
                  Icons.add,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: isLargeScreen ? 36 : 24,
                )),
          ),
          appBar: AppBar(
            toolbarHeight: size.width > 600
                ? topPadding +
                    size.height * 0.08 // Gives room for notch + your content
                : kToolbarHeight, // Use default on phones
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            centerTitle: true,
            title: Text(
              'Index',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: size.width * 0.06,
                  ),
            ),
            leadingWidth: size.width * 0.40,
            leading: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.user;
                if (user == null) return const SizedBox.shrink();

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.40,
                    maxHeight: kToolbarHeight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.02, top: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BALANCE',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: size.width * 0.030,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                user.isPremium ? '∞' : user.coins.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      fontSize: size.width * 0.040,
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,                                overflow: TextOverflow.ellipsis,
                              ),
                               SizedBox(width: size.width * 0.01),
                                Image.asset(
                                IconManager.coin,
                                height: size.height * 0.025,
                                width: size.width * 0.045,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            actions: [
              UserProfileImage(
                buildProfileImageRadius: radius,
                fallbackWidgetRadius: radius,
                placeholderWidgetRadius: radius,
                height: avatarSize,
                width: avatarSize,
              ),
              SizedBox(
                width: size.width * 0.03,
              )
            ],
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(size.height * 0.08),
                child: Padding(
                  padding:EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                ),
                  child: TextField(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: size.width * 0.04,
                        ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchTaskScreen(),
                        )),
                    readOnly: true,
                    decoration: InputDecoration(
                      isDense: true, // 🔑 IMPORTANT
                      contentPadding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.015,
                      ),
                      
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: isDarkMode
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xffE5E5E5),
                      hintText: 'Search for your task...',
                      hintStyle: TextStyle(
                          color: Color(0xff979797),
                          fontSize: size.width * 0.04),
                      prefixIconConstraints: BoxConstraints(
                        minHeight: size.height * 0.03,
                        minWidth: size.width * 0.03,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                            left: size.width * 0.03, right: size.width * 0.02),
                        child: Image.asset(
                          IconManager.search,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                )),
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
              if (!mounted) return;
              await _onRefresh(size: size);
              _refreshController.refreshCompleted();
            },
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.tasks.isNotEmpty || provider.isLoading)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: textContainer(text: 'Today', size: size),
                        ),
                      ),
                    Consumer<TaskProvider>(
                      builder: (context, taskProvider, _) {
                        if (taskProvider.isLoading) {
                          return Column(
                            children: List.generate(
                                provider.tasks.isEmpty
                                    ? 3
                                    : provider.tasks.length,
                                (index) => buildShimmerTask(
                                    size.width, size.height, isDarkMode)),
                          );
                        }
                        if (!taskProvider.isLoading &&
                            taskProvider.tasks.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return Column(
                          children: taskProvider.tasks
                              .map((task) => TaskItems(
                                size: size,
                                    task: task,
                                    selectedTask: (task) {
                                      final selectedTk = taskProvider.tasks
                                          .where((tk) => tk.id == task.id)
                                          .toList();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditTaskView(task: selectedTk),
                                          ));
                                    },
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    if (provider.completedTasks.isNotEmpty ||
                        provider.isLoading)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 20),
                          child: textContainer(text: 'Completed', size: size),
                        ),
                      ),
                    Consumer<TaskProvider>(
                      builder: (context, taskProvider, _) {
                        if (taskProvider.isLoading) {
                          return Column(
                            children: List.generate(
                              provider.completedTasks.isEmpty
                                  ? 3
                                  : provider.completedTasks.length,
                              (index) => buildShimmerTask(
                                size.width,
                                size.height,
                                Theme.of(context).brightness == Brightness.dark,
                              ),
                            ),
                          );
                        }

                        if (!taskProvider.isLoading &&
                            taskProvider.completedTasks.isEmpty) {
                          return SizedBox.shrink();
                        }

                        return Column(
                          children: taskProvider.completedTasks
                              .map((task) => CompletedTaskItems(
                                size: size,
                                    completedTask: task,
                                    selectedCompletedTask: (completedTask) {
                                      final selectedCompletedTk = taskProvider
                                          .completedTasks
                                          .where((completedTk) =>
                                              completedTk.id ==
                                              completedTask.id)
                                          .toList();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditTaskView(
                                                task: selectedCompletedTk),
                                          ));
                                    },
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    if (!provider.isLoading &&
                        provider.tasks.isEmpty &&
                        provider.completedTasks.isEmpty)
                      fallBackWidget(size: size),
                    SizedBox(
                      height: size.height * 0.02,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  fallBackWidget({required Size size}) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              SizedBox(
                  height: size.height * 0.3, // 👈 use % height instead
                  child: Image.asset(
                      fit: BoxFit.contain, AssetsManager.checklistImage)),
              SizedBox(
                height: size.height * 0.03,
              ),
              Text(
                softWrap: false,
                textAlign: TextAlign.center,
                'What do you want to do today?',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontSize: size.width * 0.06,
                    ),
              ),
              Text(
                textAlign: TextAlign.center,
                'Tap + to add your tasks',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: size.width * 0.04,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textContainer({required String text, required Size size}) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.009,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5),
          borderRadius: BorderRadius.circular(screenWidth * 0.015),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: screenWidth * 0.040,
                  ),
            ),
            SizedBox(width: screenWidth * 0.03),
            SizedBox(
              width: screenWidth * 0.03,
              height: screenWidth * 0.03,
              child: Image.asset(
                fit: BoxFit.contain,
                IconManager.arrowDown,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh({required Size size}) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final focusProvider =
        Provider.of<FocusModeProvider>(context, listen: false);
    final isConnected = await hasNetwork();
    if (!isConnected) {
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
          'No internet connection. Connect to the internet and try again',
          color: Colors.black.withOpacity(0.5),
          position: DelightSnackbarPosition.bottom,
        );
      }
      _refreshController.refreshFailed();
      return;
    }

    // Proceed with normal refresh if network is available
    await userProvider.loadUser(uid);
    if (!mounted) return;
    await taskProvider.getInitialData(uid, context);
    if (!mounted) return;
    await taskProvider.saveFcmToken(uid);
    if (!mounted) return;
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    await focusProvider.fetchUsageStats(start: startToday, end: now);
    if (!mounted) return;
    await focusProvider.fetchDailyFocusHours();
    if (!mounted) return;

    if (mounted) setState(() {});
  }
}
