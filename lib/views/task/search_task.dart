import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/components/index/task_items.dart';
import 'package:doova/r.dart';
import 'package:doova/views/task/edit_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class SearchTaskScreen extends StatefulWidget {
  const SearchTaskScreen({super.key, this.showcaseKeys});
  final List<GlobalKey>? showcaseKeys;
  @override
  State<SearchTaskScreen> createState() => _SearchTaskScreenState();
}

class _SearchTaskScreenState extends State<SearchTaskScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isSearching = false;

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.showcaseKeys != null && widget.showcaseKeys!.isNotEmpty) {
        ShowCaseWidget.of(context).startShowCase(widget.showcaseKeys!);
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final taskProvider = context.read<TaskProvider>();
    final recent = await taskProvider.getRecentSearches(uid);

    if (!mounted) return;

    setState(() {
      _recentSearches = recent;
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final taskProvider = context.read<TaskProvider>();
    await taskProvider.saveRecentSearch(uid, query);

    _loadRecentSearches(); // Refresh recent searches
  }

  Future<void> _clearRecentSearches() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final taskProvider = context.read<TaskProvider>();
    await taskProvider.clearAllRecentSearches(uid);

    setState(() {
      _recentSearches.clear();
    });
  }

  void _onSearchChanged(String value) async {
    setState(() {
      _isSearching = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final trimmedValue = value.trim();

    setState(() {
      _query = trimmedValue;
      _isSearching = false;
    });

    if (trimmedValue.isNotEmpty) {
      await _saveRecentSearch(trimmedValue);
    }
  }

  void _setQuery(String value) {
    _searchController.text = value;
    _onSearchChanged(value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final results =
        _query.trim().isEmpty ? [] : taskProvider.searchTasks(_query);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    width: size.width * 0.94,
                    height: size.height * 0.06,
                    child: TextField(
                      cursorHeight: size.height * 0.03,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: size.width * 0.04,
                          ),
                      controller: _searchController,
                      autofocus: true,
                      cursorColor: isDarkMode ? Colors.white : Colors.black,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.02,
                          vertical: size.height * 0.015,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xffE5E5E5),
                        hintText: 'Type a task title to search',
                        hintStyle: TextStyle(
                          color: Color(0xff979797),
                          fontSize: size.width * 0.04,
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minHeight: size.height * 0.03,
                          minWidth: size.width * 0.03,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              left: size.width * 0.03,
                              right: size.width * 0.02),
                          child: Image.asset(
                              fit: BoxFit.contain, IconManager.search),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        if (_isSearching) {
                          return ListView.builder(
                            itemCount: results.isEmpty ? 3 : results.length,
                            itemBuilder: (context, index) {
                              return buildShimmerTask(
                                size.width,
                                size.height,
                                isDarkMode,
                              );
                            },
                          );
                        } else if (_query.isEmpty &&
                            _recentSearches.isNotEmpty) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Searches',
                                      style: TextStyle(
                                        color: const Color(0xff979797),
                                        fontSize: size.width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _clearRecentSearches,
                                      child: Text(
                                        'Clear All',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color: Colors.red,
                                                fontSize: size.width * 0.03),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: _recentSearches
                                      .map(
                                        (search) => ActionChip(
                                          label: Text(
                                            search,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                    fontSize:
                                                        size.width * 0.03),
                                          ),
                                          onPressed: () => _setQuery(search),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          );
                        } else if (_query.isNotEmpty && results.isEmpty) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'No result for "${_query.trim()}"',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: const Color(0xff979797),
                                          fontSize: size.width * 0.06,
                                        ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.0030,
                                  ),
                                  Text(
                                    'We couldn\'t find any tasks matching your search. Try a different keyword',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: const Color(0xff979797),
                                          fontSize: size.width * 0.04,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (_query.isNotEmpty && results.isNotEmpty) {
                          return ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final task = results[index];
                              return TaskItems(
                                size: size,
                                task: task,
                                selectedTask: (tasks) {
                                  final selectedTk = taskProvider.tasks
                                      .where((tk) => tk.id == tasks.id)
                                      .toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTaskView(
                                        task: selectedTk,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
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
}
