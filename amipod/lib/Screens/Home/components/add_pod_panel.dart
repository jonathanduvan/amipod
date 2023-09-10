import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:provider/provider.dart';

class CreatePodForm extends StatefulWidget {
  final String option;
  final Function closePanel;
  final Function removeSelection;
  final Widget searchResults;
  final Map<String, ContactModel> selectedContacts;
  final Map<String, ConnectionModel> selectedConnections;

  const CreatePodForm(
      {Key? panelKey,
      required this.option,
      required this.closePanel,
      required this.removeSelection,
      required this.searchResults,
      required this.selectedContacts,
      required this.selectedConnections})
      : super(key: panelKey);

  @override
  State<CreatePodForm> createState() => CreatePodFormState();
}

class CreatePodFormState extends State<CreatePodForm> {
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
  }

  // bool isContactInPod(String id) {
  //   return (selectedContacts.containsKey(id) ||
  //       selectedConnections.containsKey(id));
  // }

  bool createPod() {
    if (title == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add a title to your pod',
            style: TextStyle(color: backgroundColor),
          ),
          backgroundColor: Colors.amber,
        ),
      );
      return false;
    }

    bool checkTitle =
        Provider.of<ConnectionsContactsModel>(context, listen: false)
            .checkPodTitle(title, null);

    print('we checked the tilte and got');
    print(checkTitle);
    if (!checkTitle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pod title already exists. Choose a different title',
            style: TextStyle(color: backgroundColor),
          ),
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

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen

    mergedContacts = mergeContactsAndConnections();

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(
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
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text('New Pod',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 30)),
              ],
            )),
        const SizedBox(
          height: 30.0,
        ),
        Container(
            padding: const EdgeInsets.only(left: 20.0, right: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _profileFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                        keyboardType: TextInputType.name,
                        keyboardAppearance: Brightness.dark,
                        controller: titleTextController,
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                const Text('Pod Members',
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w300,
                        fontSize: 22)),
                const SizedBox(
                  height: 10,
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
                                      style: const TextStyle(
                                          color: backgroundColor),
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
                                    style: TextStyle(color: backgroundColor)),
                              ));
                            },
                          )
                        : Center(
                            child: Text(
                                "Use the search bar to add connections and contacts",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                )))),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: () {
                      createPod();
                    },
                    child: const Text('Create Pod',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ))
              ],
            )),
      ],
    );
  }
}
