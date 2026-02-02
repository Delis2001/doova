import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileModalItems extends StatefulWidget {
  const ProfileModalItems({super.key, required this.size});
  final Size size;

  @override
  State<ProfileModalItems> createState() => _ProfileModalItemsState();
}

class _ProfileModalItemsState extends State<ProfileModalItems> {
  @override
  void initState() {
    Provider.of<ImageProviderNotifier>(context, listen: false)
        .retrieveLostData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.read<ImageProviderNotifier>();
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: widget.size.height * 0.3,
      width: widget.size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        color: isDarkMode ? const Color(0xFF2C2C2E): const Color(0xffE5E5E5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: widget.size.height * 0.030,
          ),
          Text(
            'Change account Image',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: widget.size.width * 0.06),
          ),
          const Row(
            children: [Expanded(child: Divider())],
          ),
          takePictureButton(context, widget.size, () async {
            context.pop();
            await imageProvider.pickImage(ImageSource.camera,widget.size );
          }),
          SizedBox(
            height: widget.size.height * 0.02,
          ),
          uploadImageButton(context, widget.size, () async {
               context.pop();
            await imageProvider.pickImage(ImageSource.gallery,widget.size);
          })
        ],
      ),
    );
  }
}

uploadImageButton(BuildContext context, Size size, void Function() onTap) {
  var isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          shape: WidgetStatePropertyAll(OutlinedBorder.lerp(
               BeveledRectangleBorder(
                  side: BorderSide(color: Color(0xff6F24E9), width: size.width * 0.0030)),
               BeveledRectangleBorder(
                  side: BorderSide(color: Color(0xff6F24E9), width: size.width * 0.0030)),
              BorderSide.strokeAlignOutside)),
          backgroundColor:
              WidgetStatePropertyAll(isDarkMode ? Colors.black : Colors.white),
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: onTap,
      child: Text(
        'Upload from device',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: const Color(0xff6F24E9),fontSize: size.width * 0.04),
      ));
}

takePictureButton(BuildContext context, Size size, void Function() onTap) {
  return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          minimumSize: WidgetStatePropertyAll(
              Size(size.width * 0.90, size.height * 0.06))),
      onPressed: onTap,
      child: Text(
        'Take a picture',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: size.width * 0.04),
      ));
}
