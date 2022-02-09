import 'package:amipod/constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Permission widget containing information about the passed [Permission]
class AddButtonWidget extends StatefulWidget {
  /// Constructs a [AddButtonWidget] for the supplied [Permission]

  final int currentIndex;
  final List<String> addButtonOptions;
  final VoidCallback onAddPressed;
  const AddButtonWidget(
      {Key? key,
      required this.currentIndex,
      required this.addButtonOptions,
      required this.onAddPressed})
      : super(key: key);

  @override
  _AddButtonWidgetState createState() => _AddButtonWidgetState();
}

class _AddButtonWidgetState extends State<AddButtonWidget> {
  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print('complete');
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> handleAddPress(int currentIndex, List addButtonOptions) async {}

  List<PopupMenuItem> setupOptions(List addButtonOptions) {
    var options = addButtonOptions
        .map((option) => PopupMenuItem(
            child: Text('${option}'),
            value: option,
            onTap: widget.onAddPressed))
        .toList();

    return (options);
  }

  @override
  Widget build(BuildContext context) {
    List<PopupMenuItem> popupOptions = setupOptions(widget.addButtonOptions);

    return PopupMenuButton(
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: ShapeDecoration(
            color: Colors.lightBlue,
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
