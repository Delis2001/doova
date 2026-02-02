import 'package:doova/components/indicator.dart';
import 'package:doova/constant/dummy.dart';
import 'package:doova/model/add_task/category.dart';
import 'package:doova/provider/task/task_provider.dart';
import 'package:doova/provider/monetizing/user_provider.dart';
import 'package:doova/utils/helpers/dialog_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker_plus/flutter_iconpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateNewCategoryScreen extends StatefulWidget {
  const CreateNewCategoryScreen({super.key});

  @override
  State<CreateNewCategoryScreen> createState() =>
      _CreateNewCategoryScreenState();
}

class _CreateNewCategoryScreenState extends State<CreateNewCategoryScreen> {
  final TextEditingController categoryNameController = TextEditingController();
  IconData? selectedIcon;
  Color? selectedColor;
  late UserProvider userProvider;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUser(uid);
    super.initState();
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets;
    final isLoading = context.watch<TaskProvider>().isLoading;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: keyboardSpace.bottom),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      _buildTitle(context, size),
                      SizedBox(height: size.height * 0.025),
                      _buildLabel(context, size, 'Category name :'),
                      SizedBox(height: size.height * 0.015),
                      NameTextField(
                          size: size,
                          categoryNameController: categoryNameController),
                      SizedBox(height: size.height * 0.025),
                      _buildLabel(context, size, 'Category icon :'),
                      SizedBox(height: size.height * 0.015),
                      _buildIconSelector(context, size),
                      SizedBox(height: size.height * 0.025),
                      _buildLabel(context, size, 'Category color :'),
                      _buildColorSelector(size),
                      SizedBox(
                        height: size.height * 0.3,
                      ),
                      _buildButtonRow(size),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                    ],
                  ),
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
        ]);
      },
    );
  }

  Widget _buildTitle(BuildContext context, Size size) {
    return Text(
      'Create new category',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: size.width * 0.06,
          ),
    );
  }

  Widget _buildLabel(BuildContext context, Size size, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _buildIconSelector(BuildContext context, Size size) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final icon = await FlutterIconPicker.showIconPicker(
          context,
          iconPackModes: [IconPack.cupertino],
          barrierDismissible: false,
        );
        if (icon != null) {
          setState(() => selectedIcon = icon);
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height * 0.06,
        width: selectedIcon == null ? size.width * 0.5 : size.width * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDarkMode ? const Color(0xff535353) : const Color(0xffE5E5E5),
        ),
        child: selectedIcon == null
            ? Text(
                'Choose icon from library',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: size.width * 0.04,
                    ),
              )
            : Icon(selectedIcon),
      ),
    );
  }

  Widget _buildColorSelector(Size size) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: size.height * 0.13,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryColor.length,
        itemBuilder: (context, index) {
          final color = categoryColor[index];
          final isSelected = selectedColor == color;

          return GestureDetector(
            onTap: () => setState(() => selectedColor = color),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
              height: size.height * 0.14,
              width: size.width * 0.14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: isDarkMode ? Colors.white : Colors.black,
                        width: size.width * 0.0050,
                      )
                    : null,
              ),
              child: isSelected
                  ? Icon(Icons.check,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: size.width * 0.06)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonRow(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: size.width * 0.04,
        ),
        cancelButton(context, size),
        SizedBox(width: size.width * 0.03),
        ElevatedButton(
          onPressed: () => _handleSubmit(size),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff6F24E9),
            fixedSize: Size(size.width * 0.5, size.height * 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size.width * 0.01),
            ),
          ),
          child: Text(
            'Create Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: size.width * 0.04,
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit(Size size) async {
    final name = categoryNameController.text.trim();
    if (name.isEmpty || selectedIcon == null || selectedColor == null) {
      taskErrorDialog(
          context, 'Please provide a name, icon, and color for the category', size);
      return;
    }

    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;

    if (!user.isPremium && user.coins <= 0) {
      monetizingDialog(context, size);
      return;
    }
    final newCategory = CategoryModel(
      title: name,
      icon: selectedIcon!,
      color: selectedColor!,
    );
    final success =
        await context.read<TaskProvider>().addCategory(newCategory, context);
    if (!mounted) return;

    if (success) {
      await userProvider.spendCoin(user.uid);
      if (!mounted) return;
      context.pop();
    }
  }
}

// --- Cancel Button ---
Widget cancelButton(BuildContext context, Size size) {
  return TextButton(
    onPressed: () => Navigator.of(context).pop(),
    child: Text(
      'Cancel',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: size.width * 0.04,
            color: const Color(0xff6F24E9),
          ),
    ),
  );
}

// --- Name TextField Widget ---
class NameTextField extends StatelessWidget {
  const NameTextField(
      {super.key, required this.categoryNameController, required this.size});
  final TextEditingController categoryNameController;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    //  final textFieldHeight = (size.height * 0.07).clamp(50.0, 70.0);
    return TextField(
      textCapitalization: TextCapitalization.none,
      autofocus: false,
      controller: categoryNameController,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontSize: size.width * 0.04),
      cursorColor: const Color(0xff979797),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'[a-z\s]')), // only lowercase letters and space
        LengthLimitingTextInputFormatter(
            12), // max length that fits your GridView well
        LowerCaseTextFormatter(), // custom formatter defined below
      ],
      decoration: InputDecoration(
        hintText: 'Category name',
        filled: true,
        fillColor:
            isDarkMode ? const Color(0xff2C2C2C) : const Color(0xffF0F0F0),

        // Normal enabled border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            width: 1,
          ),
        ),

        // Border when focused (no error)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          borderSide:
              BorderSide(color: Color(0xff6F24E9), width: size.width * 0.0030),
        ),

        // Border when error occurs (not focused)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          borderSide: BorderSide(color: Colors.red, width: size.width * 0.0030),
        ),

        // Border when error occurs and field is focused
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          borderSide: BorderSide(color: Colors.red, width: size.width * 0.0030),
        ),
      ),
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
