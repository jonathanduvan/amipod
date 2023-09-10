import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/HiveModels/pod_model.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:dipity/Screens/Home/components/viewPanels/view_pod.dart';
import 'package:dipity/Screens/Home/components/viewPanels/view_connection.dart';
import 'package:dipity/Screens/Home/components/viewPanels/view_contact.dart';

class BlockedContactsView extends StatefulWidget {
  final String option;
  final Function closePanel;
  final Function removeSelection;
  final Widget searchResults;
  final Map<String, ContactModel> selectedContacts;
  final Map<String, ConnectionModel> selectedConnections;

  const BlockedContactsView(
      {Key? panelKey,
      required this.option,
      required this.closePanel,
      required this.removeSelection,
      required this.searchResults,
      required this.selectedContacts,
      required this.selectedConnections})
      : super(key: panelKey);

  @override
  State<BlockedContactsView> createState() => BlockedContactsViewState();
}

class BlockedContactsViewState extends State<BlockedContactsView> {
  final _profileFormKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();

  List mergedContacts = [];
  String title = '';
  bool isChecked = false;

  HiveAPI hiveApi = HiveAPI(); // TODO: call function for addpods

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  bool checkList(Iterable<dynamic> infoList) {
    if (infoList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
    ;
  }

  // bool isContactInPod(String id) {
  //   return (selectedContacts.containsKey(id) ||
  //       selectedConnections.containsKey(id));
  // }

  bool createPod() {
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
        .addPod(widget.selectedConnections, widget.selectedContacts, title);

    bool podNotCreated = (newPod == null);

    if (!podNotCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Pod Created!')),
      );
      widget.closePanel();
      clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an issue creating your Pod')),
      );
    }

    return false;
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

  List<dynamic> mergeContactsAndConnections(
      Iterable<dynamic> bContacts, Iterable<dynamic> bConnections) {
    List mergedCons = [];

    for (var value in bConnections) {
      mergedCons.add(value);
    }

    for (var value in bContacts) {
      mergedCons.add(value);
    }

    return mergedCons;
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    Iterable<dynamic> blockedContacts =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.blockedContacts);
    Iterable<dynamic> blockedConnections =
        context.select<ConnectionsContactsModel, Iterable<dynamic>>(
            (ccModel) => ccModel.blockedConnections);

    mergedContacts =
        mergeContactsAndConnections(blockedContacts, blockedConnections);
    return Container(
        child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 10.0,
        ),
        Container(
            alignment: Alignment.topRight,
            child: Row(
              children: [
                IconButton(
                  // backgroundColor: backgroundColor,
                  // mini: true,
                  onPressed: () => {widget.closePanel()},
                  icon: Icon(
                    Icons.arrow_back_outlined,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text('Block List',
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w300,
                        fontSize: 30)),
              ],
            )),
        SizedBox(
          height: 30.0,
        ),
        Container(
            padding: const EdgeInsets.only(left: 20.0, right: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                    "Contacts and connections you don't want to share your location with:",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 17.0,
                    )),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: size.width * .95,
                    height: size.height * .30,
                    decoration: BoxDecoration(
                        // color: Colors.grey[100],
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                            top: BorderSide(color: Colors.grey, width: 0.5))),
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
                                      style: TextStyle(color: backgroundColor),
                                    )),
                                trailing: IconButton(
                                    onPressed: () {
                                      widget.removeSelection(c.id, isConnect);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: backgroundColor,
                                    )),
                                title: Text(c.name,
                                    style: TextStyle(color: backgroundColor)),
                              ));
                            },
                          )
                        : Center(
                            child: Text("The block list is empty.",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                )))),
                SizedBox(
                  height: 20,
                ),
              ],
            )),
        // widget.searchResults
      ],
    ));
  }
}
