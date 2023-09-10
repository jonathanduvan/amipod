import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ViewPodFormPanel extends StatefulWidget {
  final String id;
  final Function closePanel;
  final Function editModeToggled;
  final Function removeSelection;
  final Function updateSelections;
  final Map<String, ContactModel> selectedContacts;
  final Map<String, ConnectionModel> selectedConnections;
  final Function onPodDeleted;
  const ViewPodFormPanel(
      {Key? panelKey,
      required this.id,
      required this.closePanel,
      required this.editModeToggled,
      required this.removeSelection,
      required this.updateSelections,
      required this.selectedContacts,
      required this.selectedConnections,
      required this.onPodDeleted})
      : super(key: panelKey);

  @override
  State<ViewPodFormPanel> createState() => ViewPodForm();
}

class ViewPodForm extends State<ViewPodFormPanel> {
  final _profileFormKey = GlobalKey<FormState>();

  bool editMode = false;

  final titleTextController = TextEditingController();
  List mergedContacts = [];

  String title = '';
  bool isChecked = false;

  HiveAPI hiveApi = HiveAPI(); // TODO: call function for addpods

  bool checkList(Iterable<dynamic> infoList) {
    if (infoList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
    ;
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return primaryColor;
  }

  clearForm() {
    titleTextController.clear();
  }

  bool updatePod() {
    if (title == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a title to your pod',
              style: TextStyle(color: backgroundColor)),
          backgroundColor: Colors.amber,
        ),
      );
      return false;
    }

    var newPod = Provider.of<ConnectionsContactsModel>(context, listen: false)
        .updatePod(widget.id, widget.selectedConnections,
            widget.selectedContacts, title);

    bool podNotCreated = (newPod == null);

    if (!podNotCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pod Updated!')),
      );
      widget.editModeToggled(!editMode);
      setState(() {
        editMode = !editMode;
      });
      widget.closePanel();
      clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an issue updating your Pod')),
      );
    }

    return false;
  }

  List<dynamic> mergeContactsAndConnections() {
    List mergedCons = [];

    widget.selectedConnections.forEach((key, value) {
      mergedCons.add(value);
    });
    widget.selectedContacts.forEach((key, value) {
      mergedCons.add(value);
    });

    return mergedCons;
  }

  bool isEdited(PodModel pod) {
    if ((pod.name != title) && (title != '')) {
      return true;
    } else if (pod.connections?.length != widget.selectedConnections.length) {
      return true;
    } else if (pod.contacts?.length != widget.selectedContacts.length) {
      return true;
    } else {
      if (pod.connections != null) {
        var connection = pod.connections!.keys.firstWhere(
            (key) => !widget.selectedConnections.containsKey(key),
            orElse: () => {});

        if (connection == {}) {
          return true;
        }
      }
      if (pod.contacts != null) {
        var contacts = pod.contacts!.keys.firstWhere(
            (key) => !widget.selectedContacts.containsKey(key),
            orElse: () => {});

        if (contacts == {}) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var selectedPod =
        Provider.of<ConnectionsContactsModel>(context, listen: false)
            .getPod(widget.id);
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    if (selectedPod is PodModel) {
      mergedContacts = mergeContactsAndConnections();
      List<PopupMenuEntry> popupOptions = [
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(
            editMode ? 'Cancel' : 'Edit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            widget.editModeToggled(!editMode);

            if (!editMode) {
              titleTextController.value =
                  TextEditingValue(text: selectedPod.name);
            }
            setState(() {
              editMode = !editMode;
            });
          },
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          onTap: () {
            Provider.of<ConnectionsContactsModel>(context, listen: false)
                .deletePod(selectedPod);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${selectedPod.name} Pod was deleted')),
            );

            widget.onPodDeleted();

            widget.closePanel();
          },
        ),
      ];
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                editMode
                    ? Container(
                        width: size.width * .75,
                        child: TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          keyboardType: TextInputType.name,
                          keyboardAppearance: Brightness.dark,
                          controller: titleTextController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: "Pod Name",
                            focusColor: primaryColor,
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid pod name.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              title = value;
                            });
                          },
                        ))
                    : Text('${selectedPod.name}',
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 30)),
                Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.white),
                  ),
                  child: PopupMenuButton(
                      offset: Offset(-45.0, 41.0),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                        ),
                        child: Icon(Icons.menu, color: primaryColor, size: 30),
                      ),
                      itemBuilder: (context) => popupOptions),
                )
              ],
            ),
            Container(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Text('Pod Members',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                    Container(
                        width: size.width * .95,
                        height: size.height * .30,
                        decoration: BoxDecoration(
                            // color: Colors.grey[100],
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 0.5),
                                top: BorderSide(
                                    color: Colors.grey, width: 0.5))),
                        child: mergedContacts.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: mergedContacts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var c = mergedContacts.elementAt(index);
                                  bool isConnect = c is ConnectionModel;

                                  return Container(
                                      // decoration: new BoxDecoration(
                                      //     // color: backgroundColor,
                                      //     border: new Border(
                                      //         bottom: new BorderSide(
                                      //             color: Colors.grey, width: 0.5))),
                                      child: ListTile(
                                    leading: CircleAvatar(
                                        backgroundColor: isConnect
                                            ? primaryColor
                                            : Colors.grey[300],
                                        child: Text(
                                          c.initials,
                                          style:
                                              TextStyle(color: backgroundColor),
                                        )),
                                    trailing: IconButton(
                                        onPressed: () {
                                          widget.removeSelection(c.id);
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: backgroundColor,
                                        )),
                                    title: Text(c.name,
                                        style:
                                            TextStyle(color: backgroundColor)),
                                  ));
                                },
                              )
                            : Text(
                                "Use the search bar to add connections and contacts",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                ))),
                    SizedBox(
                      height: 20,
                    ),
                    isEdited(selectedPod)
                        ? Center(
                            child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: primaryColor),
                              onPressed: () {
                                updatePod();
                              },
                              child: const Text('Update Pod',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                          ))
                        : SizedBox.shrink()
                  ],
                ))
          ],
        ),
      );
    } else {
      return Container(
        child: Text('No Pod to Display'),
      );
    }
  }
}
