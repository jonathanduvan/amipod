import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

// Permission widget containing information about the passed [Permission]
class AddButtonWidget extends StatefulWidget {
  /// Constructs a [AddButtonWidget] for the supplied [Permission]

  final List<String> addButtonOptions;
  final ArgumentCallback onAddPressed;
  const AddButtonWidget(
      {Key? key, required this.addButtonOptions, required this.onAddPressed})
      : super(key: key);

  @override
  _AddButtonWidgetState createState() => _AddButtonWidgetState();
}

class _AddButtonWidgetState extends State<AddButtonWidget> {
  @override
  void initState() {
    super.initState();
    // _askPermissions();
  }

  List<PopupMenuItem> setupOptions(List addButtonOptions) {
    var options = addButtonOptions
        .map((option) => PopupMenuItem(
              value: option,
              onTap: () {
                widget.onAddPressed(option);
              },
              child: Text('${option}'),
            ))
        .toList();

    return (options);
  }

  @override
  Widget build(BuildContext context) {
    List<PopupMenuItem> popupOptions = setupOptions(widget.addButtonOptions);

    return PopupMenuButton(
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: const ShapeDecoration(
            color: primaryColor,
            shape: CircleBorder(),
          ),
          child: Icon(Icons.add, color: backgroundColor, size: 30),
        ),
        itemBuilder: (context) => popupOptions);
  }
}

class CustomPopupMenu {
  CustomPopupMenu({
    required this.title,
  });
  String title;
}
