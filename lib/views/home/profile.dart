import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:doova/components/indicator.dart';
import 'package:doova/components/profile/app_settings.dart';
import 'package:doova/components/profile/user_profile_image.dart';
import 'package:doova/provider/auth/auth_provider.dart';
import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/r.dart';
import 'package:doova/utils/helpers/dialog_helper.dart';
import 'package:doova/utils/helpers/modal_helper.dart';
import 'package:doova/components/profile/setting_listile_widget.dart';
import 'package:doova/components/profile/task_card_widget.dart';
import 'package:doova/utils/helpers/network_checker.dart';
import 'package:doova/utils/helpers/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {super.key,
      this.showcaseKeys,
      this.onShowcaseComplete,
      this.onShowcaseRequested});
  final List<GlobalKey>? showcaseKeys;
  final VoidCallback? onShowcaseComplete;
  final void Function(List<GlobalKey>)? onShowcaseRequested;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    context.read<ImageProviderNotifier>().getBuildContext(context);
    final pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = context.read<AuthProvider>().fullName;
    final email = context.read<AuthProvider>().email;
    setState(() {
      nameController.text = name ?? pref.getString('Name') ?? '';
      emailController.text = email ?? pref.getString('email') ?? '';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    oldPasswordController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final isLoading = context.watch<AuthProvider>().isLoading;
    final task = context.watch<TaskProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final screenWidth = size.width;
        final avatarSize = screenWidth * 0.20;
        double radius = size.width * 0.1;
        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: size.width > 600
                    ? topPadding +
                        size.height *
                            0.08 // Gives room for notch + your content
                    : kToolbarHeight, // Use default on phones,
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                centerTitle: true,
                title: Text('Profile',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: size.width * 0.06)),
              ),
              body: SafeArea(
                child: SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: false,
                  header: CustomHeader(
                    height: size.height * 0.1,
                    builder: (context, mode) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildCustomSpinner(context, size),
                        ),
                      );
                    },
                  ),
                  onRefresh: () async {
                    await onRefresh(size);
                  },
                  child: Consumer<AuthProvider>(
                    builder: (context, provider, _) {
                      final name = provider.fullName;

                      return SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: size.height * 0.03),
                                  UserProfileImage(
                                    buildProfileImageRadius: radius,
                                    fallbackWidgetRadius: radius,
                                    height: avatarSize,
                                    width: avatarSize,
                                    placeholderWidgetRadius: radius,
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    name ?? nameController.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(fontSize: size.width * 0.06),
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: TaskCard(
                                            label:
                                                '${task.tasks.length} Task left',
                                            isDarkMode: isDarkMode,
                                            size: size),
                                      ),
                                      SizedBox(width: size.width * 0.05),
                                      Flexible(
                                        child: TaskCard(
                                            label:
                                                '${task.completedTasks.length} Task done',
                                            isDarkMode: isDarkMode,
                                            size: size),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   SectionHeader(title: 'Settings',size: size,),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AppSettings(),
                                        )),
                                    icon: IconManager.setting,
                                    title: 'App Settings',
                                    isDarkMode: isDarkMode,
                                  ),
                                   SectionHeader(title: 'Account',size: size,),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => nameDialog(
                                      size: size,
                                      context: context,
                                      formKey: _formKey,
                                      nameController: nameController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        final parts =
                                            value.trim().split(RegExp(r'\s+'));
                                        if (parts.length < 2) {
                                          return 'Please enter both first and last name';
                                        }
                                        return null;
                                      },
                                      onSaved: (_) =>
                                          FocusScope.of(context).unfocus(),
                                    ),
                                    icon: IconManager.user1,
                                    title: 'Change account name',
                                    isDarkMode: isDarkMode,
                                  ),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => emailDialog(
                                      size: size,
                                      context: context,
                                      emailController: emailController,
                                      formKey: _formKey,
                                      onSaved: (_) =>
                                          FocusScope.of(context).unfocus(),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your email';
                                        } else if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                          return 'Invalid email format';
                                        }
                                        return null;
                                      },
                                    ),
                                    icon: IconManager.email,
                                    isEmailIcon: true,
                                    title: 'Change account email',
                                    isDarkMode: isDarkMode,
                                  ),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => passwordDialog(
                                      size: size,
                                      newPasswordController:
                                          newPasswordController,
                                      oldPasswordController:
                                          oldPasswordController,
                                      context: context,
                                      formKey: _formKey,
                                      oldPasswordValidator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your old password';
                                        } else if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      newPasswordValidator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter a new password';
                                        } else if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      onSaved: (_) =>
                                          FocusScope.of(context).unfocus(),
                                    ),
                                    icon: IconManager.key,
                                    title: 'Change account password',
                                    isDarkMode: isDarkMode,
                                  ),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => imagePicker(context,size),
                                    icon: IconManager.camera,
                                    title: 'Change account Image',
                                    isDarkMode: isDarkMode,
                                  ),
                                  
                                   SectionHeader(title: 'Doova',size: size,),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => aboutDoovaDialog(context, size),
                                    icon: IconManager.menu,
                                    title: 'About Doova',
                                    isDarkMode: isDarkMode,
                                  ),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => fAQDialog(context, size),
                                    icon: IconManager.infoCircle,
                                    title: 'FAQ',
                                    isDarkMode: isDarkMode,
                                  ),
                                  SettingsListTile(
                                    size: size,
                                    onTap: _launchWhatsApp,
                                    icon: IconManager.flash,
                                    title: 'Help & Support',
                                    isDarkMode: isDarkMode,
                                  ),
                                  SettingsListTile(
                                    size: size,
                                    onTap: () => logoutDialog(
                                      size: size,
                                      context,
                                    ),
                                    icon: IconManager.logout,
                                    title: 'Log Out',
                                    isDarkMode: isDarkMode,
                                    isLogout: true,
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                    child: LoadingIndicator(
                  size: size,
                )),
              ),
          ],
        );
      },
    );
  }

  Future<void> _launchWhatsApp() async {
    final String whatsappUrl = "https://wa.link/fhi1ng";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not open WhatsApp.");
    }
  }

  Future<void> onRefresh(Size size) async {
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
      await fetchData();
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
