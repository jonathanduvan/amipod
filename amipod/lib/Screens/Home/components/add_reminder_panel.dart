import 'package:dipity/HiveModels/connection_model.dart';
import 'package:dipity/HiveModels/contact_model.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Services/hive_api.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateReminderForm extends StatefulWidget {
  final String option;
  final Function closePanel;
  final Function removeSelection;
  final dynamic checkInPerson;

  const CreateReminderForm(
      {Key? panelKey,
      required this.option,
      required this.closePanel,
      required this.removeSelection,
      required this.checkInPerson})
      : super(key: panelKey);

  @override
  State<CreateReminderForm> createState() => CreateReminderFormState();
}

class CreateReminderFormState extends State<CreateReminderForm> {
  final _profileFormKey = GlobalKey<FormState>();

  final titleTextController = TextEditingController();

  List<int> timeOptions = [for (var i = 1; i <= 10; i++) i];
  List<String> lengthOptions = ['day', 'week', 'month'];

  List mergedContacts = [];

  List<String> aboutTopics = [];

  bool recurring = false;

  String title = '';
  bool isChecked = false;
  DateRangePickerController drpController = DateRangePickerController();
  String reminderDate = 'Today';
  int recurringTime = 1;
  String recurringLength = 'week';
  List<bool> expanded = [false, false];

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

  bool createReminder(String name) {
    if (name == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a contact or connection to check-in with',
            style: TextStyle(color: backgroundColor),
          ),
          backgroundColor: Colors.amber,
        ),
      );
      return false;
    }

    return true;
  }

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

    // var newPod = Provider.of<ConnectionsContactsModel>(context, listen: false)
    //     .addPod(widget.selectedConnections, widget.selectedContacts, title);

    if (true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Check-in Created!')),
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

  clearForm() {
    titleTextController.clear();
  }

  onBackPressed(BuildContext context) {
    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).unfocus();
    }
    titleTextController.clear();
    widget.closePanel();
  }

  bool isSameDate(DateTime first, DateTime other) {
    return first.year == other.year &&
        first.month == other.month &&
        first.day == other.day;
  }

  void formatDate() {
    String formattedDate = '';

    if (isSameDate(DateTime.now(), drpController.selectedDate!)) {
      formattedDate = 'Today';
    } else if (isSameDate(DateTime.now().add(const Duration(days: 1)),
        drpController.selectedDate!)) {
      formattedDate = 'Tomorrow';
    } else {
      formattedDate =
          '${months[drpController.selectedDate!.month]} ${drpController.selectedDate!.day}, ${drpController.selectedDate!.year}';
    }
    setState(() {
      reminderDate = formattedDate;
    });
  }

  String formatRecurringDate() {
    if (recurringTime != 1) {
      return 'Every $recurringTime ${recurringLength}s';
    } else {
      return 'Every $recurringLength';
    }
  }

  String formatPersonName() {
    String name = '';
    print(isNullEmptyOrFalse(widget.checkInPerson));
    if (!isNullEmptyOrFalse(widget.checkInPerson)) {
      if ((widget.checkInPerson is ConnectionModel) ||
          (widget.checkInPerson is ContactModel)) {
        name = widget.checkInPerson.name;
      }
    }
    print(name);
    return name;
  }

  @override
  Widget build(BuildContext context) {
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    String name = formatPersonName();
    return ListView(
      // physics: const NeverScrollableScrollPhysics(),
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
                  onPressed: () => {onBackPressed(context)},
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text('New Check-in',
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
                Row(
                  children: [
                    const Text(
                      'With:  ',
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                    ),
                    name == ''
                        ? const Text(
                            'Use the search bar to select the person\n to check in with.',
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 14,
                                fontStyle: FontStyle.italic),
                          )
                        : Container(
                            padding: const EdgeInsets.only(
                              bottom: 5, // Space between underline and text
                            ),
                            child: InputChip(
                              labelStyle: const TextStyle(
                                  color: Colors.black, fontSize: 15),
                              label: Text(
                                name,
                              ),
                              onDeleted: () {
                                widget.removeSelection(widget.checkInPerson.id);
                              },
                              backgroundColor: primaryColor,
                            ),
                          )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                  // decoration: BoxDecoration(
                  //     border: Border(
                  //         top: BorderSide(color: Colors.red, width: 0.5))),

                  child: Column(
                    children: [
                      SizedBox(
                        width: size.width - 100,
                        child: Form(
                          key: _profileFormKey,
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                            keyboardType: TextInputType.name,
                            keyboardAppearance: Brightness.dark,
                            controller: titleTextController,
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                                labelText: "About",
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                focusColor: primaryColor,
                                // enabledBorder: UnderlineInputBorder(
                                //   borderSide: BorderSide(color: primaryColor),
                                // ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                disabledBorder: InputBorder.none),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter what you want to check in with this person about.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                title = value;
                              });
                            },
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty) {
                                aboutTopics.add(value);
                              }
                              titleTextController.clear();
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          aboutTopics.length,
                          (int index) {
                            return InputChip(
                              backgroundColor:
                                  const Color.fromARGB(255, 234, 234, 234),
                              label: Text(aboutTopics[index]),
                              onDeleted: () {
                                setState(() {
                                  aboutTopics.removeAt(index);
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                      SizedBox(
                        width: size.width,
                        height: 15,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !recurring
                        ? Text(
                            'Recurring',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        : Text('Recurring'),
                    Switch(
                      value: recurring,
                      onChanged: (bool newValue) {
                        setState(() {
                          recurring = newValue;
                        });
                      },
                      inactiveTrackColor: Colors.deepPurple[100],
                      inactiveThumbColor: Colors.deepPurple,
                    ),
                    recurring
                        ? Text(
                            'Once',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        : Text('Once'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                recurring
                    ? ExpansionPanelList(
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            expanded[panelIndex] = !isExpanded;
                          });
                        },
                        animationDuration: Duration(milliseconds: 500),
                        //animation duration while expanding/collapsing
                        children: [
                            ExpansionPanel(
                                backgroundColor: Colors.white,
                                headerBuilder: (context, isOpen) {
                                  return Container(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("When"),
                                          Text(
                                            reminderDate,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ));
                                },
                                body: Container(
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  color: Color.fromARGB(255, 246, 246, 246),
                                  child: SfDateRangePicker(
                                    initialSelectedDate: DateTime.now(),
                                    enablePastDates: false,
                                    controller: drpController,
                                    onSelectionChanged:
                                        (dateRangePickerSelectionChangedArgs) {
                                      formatDate();
                                    },
                                    selectionMode:
                                        DateRangePickerSelectionMode.single,
                                  ),
                                ),
                                isExpanded: expanded[0]),
                          ])
                    : ExpansionPanelList(
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            expanded[panelIndex] = !isExpanded;
                          });
                        },
                        animationDuration: Duration(milliseconds: 500),
                        //animation duration while expanding/collapsing
                        children: [
                            ExpansionPanel(
                                backgroundColor: Colors.white,
                                headerBuilder: (context, isOpen) {
                                  return Container(
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("When"),
                                          Text(
                                            formatRecurringDate(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ));
                                },
                                body: Container(
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  color: Color.fromARGB(255, 246, 246, 246),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DropdownButton<int>(
                                        value: recurringTime,
                                        icon: const Icon(Icons.arrow_downward),
                                        elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.deepPurple),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (int? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            recurringTime = value!;
                                          });
                                        },
                                        items: timeOptions
                                            .map<DropdownMenuItem<int>>(
                                                (int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      DropdownButton<String>(
                                        value: recurringLength,
                                        icon: const Icon(Icons.arrow_downward),
                                        elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.deepPurple),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            recurringLength = value!;
                                          });
                                        },
                                        items: lengthOptions
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                isExpanded: expanded[0]),
                          ]),
                SizedBox(
                  height: 50,
                ),
                Center(
                    child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: () {
                      createReminder(name);
                    },
                    child: const Text('Create Check-in',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                )),
                SizedBox(
                  height: 20,
                )
              ],
            )),
        // widget.searchResults
      ],
    );
  }
}
