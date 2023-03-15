import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const primaryColor = Color(0xFF1DD3B0);
const backgroundColor = Color(0xFF161F20);
const dipityPurple = Color(0xFF7E2E84);
const podOrange = Color(0xFFF97068);
const dipityBlack = Color(0xFF22242F);
// Shared Preferences Keys
const firstNameKey = 'first_name';
const lastNameKey = 'last_name';
const loggedInKey = 'logged_in';

// Secure Storage Keys
const idKeyName = 'id';
const encryptionKeyName = 'encryption_key';
const iVKeyName = 'iv_key';
const userPinKeyName = 'user_pin';
const userPasswordKeyName = 'user_password';
const userPhoneNumberKeyName = 'user_phone_number';

const podsStorageKeyName = 'pods_storage_key';
const connectionsStorageKeyName = 'connections_storage_key';
const unconnectedContactsStorageKeyName = 'unconnected_contacts_storage_key';

class Country {
  final String country;
  final Double code;

  Country({required this.country, required this.code});
}

var countryCodes = {
  "Bangladesh": "880",
  "Belgium": "32",
  "Burkina Faso": "226",
  "Bulgaria": "359",
  "Bosnia and Herzegovina": "387",
  "Barbados": "+1-246",
  "Wallis and Futuna": "681",
  "Saint Barthelemy": "590",
  "Bermuda": "+1-441",
  "Brunei": "673",
  "Bolivia": "591",
  "Bahrain": "973",
  "Burundi": "257",
  "Benin": "229",
  "Bhutan": "975",
  "Jamaica": "+1-876",
  "Bouvet Island": "",
  "Botswana": "267",
  "Samoa": "685",
  "Bonaire, Saint Eustatius and Saba ": "599",
  "Brazil": "55",
  "Bahamas": "+1-242",
  "Jersey": "+44-1534",
  "Belarus": "375",
  "Belize": "501",
  "Russia": "7",
  "Rwanda": "250",
  "Serbia": "381",
  "East Timor": "670",
  "Reunion": "262",
  "Turkmenistan": "993",
  "Tajikistan": "992",
  "Romania": "40",
  "Tokelau": "690",
  "Guinea-Bissau": "245",
  "Guam": "+1-671",
  "Guatemala": "502",
  "South Georgia and the South Sandwich Islands": "",
  "Greece": "30",
  "Equatorial Guinea": "240",
  "Guadeloupe": "590",
  "Japan": "81",
  "Guyana": "592",
  "Guernsey": "+44-1481",
  "French Guiana": "594",
  "Georgia": "995",
  "Grenada": "+1-473",
  "United Kingdom": "44",
  "Gabon": "241",
  "El Salvador": "503",
  "Guinea": "224",
  "Gambia": "220",
  "Greenland": "299",
  "Gibraltar": "350",
  "Ghana": "233",
  "Oman": "968",
  "Tunisia": "216",
  "Jordan": "962",
  "Croatia": "385",
  "Haiti": "509",
  "Hungary": "36",
  "Hong Kong": "852",
  "Honduras": "504",
  "Heard Island and McDonald Islands": " ",
  "Venezuela": "58",
  "Puerto Rico": "+1-787 and 1-939",
  "Palestinian Territory": "970",
  "Palau": "680",
  "Portugal": "351",
  "Svalbard and Jan Mayen": "47",
  "Paraguay": "595",
  "Iraq": "964",
  "Panama": "507",
  "French Polynesia": "689",
  "Papua New Guinea": "675",
  "Peru": "51",
  "Pakistan": "92",
  "Philippines": "63",
  "Pitcairn": "870",
  "Poland": "48",
  "Saint Pierre and Miquelon": "508",
  "Zambia": "260",
  "Western Sahara": "212",
  "Estonia": "372",
  "Egypt": "20",
  "South Africa": "27",
  "Ecuador": "593",
  "Italy": "39",
  "Vietnam": "84",
  "Solomon Islands": "677",
  "Ethiopia": "251",
  "Somalia": "252",
  "Zimbabwe": "263",
  "Saudi Arabia": "966",
  "Spain": "34",
  "Eritrea": "291",
  "Montenegro": "382",
  "Moldova": "373",
  "Madagascar": "261",
  "Saint Martin": "590",
  "Morocco": "212",
  "Monaco": "377",
  "Uzbekistan": "998",
  "Myanmar": "95",
  "Mali": "223",
  "Macao": "853",
  "Mongolia": "976",
  "Marshall Islands": "692",
  "Macedonia": "389",
  "Mauritius": "230",
  "Malta": "356",
  "Malawi": "265",
  "Maldives": "960",
  "Martinique": "596",
  "Northern Mariana Islands": "+1-670",
  "Montserrat": "+1-664",
  "Mauritania": "222",
  "Isle of Man": "+44-1624",
  "Uganda": "256",
  "Tanzania": "255",
  "Malaysia": "60",
  "Mexico": "52",
  "Israel": "972",
  "France": "33",
  "British Indian Ocean Territory": "246",
  "Saint Helena": "290",
  "Finland": "358",
  "Fiji": "679",
  "Falkland Islands": "500",
  "Micronesia": "691",
  "Faroe Islands": "298",
  "Nicaragua": "505",
  "Netherlands": "31",
  "Norway": "47",
  "Namibia": "264",
  "Vanuatu": "678",
  "New Caledonia": "687",
  "Niger": "227",
  "Norfolk Island": "672",
  "Nigeria": "234",
  "New Zealand": "64",
  "Nepal": "977",
  "Nauru": "674",
  "Niue": "683",
  "Cook Islands": "682",
  "Kosovo": "",
  "Ivory Coast": "225",
  "Switzerland": "41",
  "Colombia": "57",
  "China": "86",
  "Cameroon": "237",
  "Chile": "56",
  "Cocos Islands": "61",
  "Canada": "1",
  "Republic of the Congo": "242",
  "Central African Republic": "236",
  "Democratic Republic of the Congo": "243",
  "Czech Republic": "420",
  "Cyprus": "357",
  "Christmas Island": "61",
  "Costa Rica": "506",
  "Curacao": "599",
  "Cape Verde": "238",
  "Cuba": "53",
  "Swaziland": "268",
  "Syria": "963",
  "Sint Maarten": "599",
  "Kyrgyzstan": "996",
  "Kenya": "254",
  "South Sudan": "211",
  "Suriname": "597",
  "Kiribati": "686",
  "Cambodia": "855",
  "Saint Kitts and Nevis": "+1-869",
  "Comoros": "269",
  "Sao Tome and Principe": "239",
  "Slovakia": "421",
  "South Korea": "82",
  "Slovenia": "386",
  "North Korea": "850",
  "Kuwait": "965",
  "Senegal": "221",
  "San Marino": "378",
  "Sierra Leone": "232",
  "Seychelles": "248",
  "Kazakhstan": "7",
  "Cayman Islands": "+1-345",
  "Singapore": "65",
  "Sweden": "46",
  "Sudan": "249",
  "Dominican Republic": "+1-809 and 1-829",
  "Dominica": "+1-767",
  "Djibouti": "253",
  "Denmark": "45",
  "British Virgin Islands": "+1-284",
  "Germany": "49",
  "Yemen": "967",
  "Algeria": "213",
  "United States": "1",
  "Uruguay": "598",
  "Mayotte": "262",
  "United States Minor Outlying Islands": "1",
  "Lebanon": "961",
  "Saint Lucia": "+1-758",
  "Laos": "856",
  "Tuvalu": "688",
  "Taiwan": "886",
  "Trinidad and Tobago": "+1-868",
  "Turkey": "90",
  "Sri Lanka": "94",
  "Liechtenstein": "423",
  "Latvia": "371",
  "Tonga": "676",
  "Lithuania": "370",
  "Luxembourg": "352",
  "Liberia": "231",
  "Lesotho": "266",
  "Thailand": "66",
  "French Southern Territories": "",
  "Togo": "228",
  "Chad": "235",
  "Turks and Caicos Islands": "+1-649",
  "Libya": "218",
  "Vatican": "379",
  "Saint Vincent and the Grenadines": "+1-784",
  "United Arab Emirates": "971",
  "Andorra": "376",
  "Antigua and Barbuda": "+1-268",
  "Afghanistan": "93",
  "Anguilla": "+1-264",
  "U.S. Virgin Islands": "+1-340",
  "Iceland": "354",
  "Iran": "98",
  "Armenia": "374",
  "Albania": "355",
  "Angola": "244",
  "Antarctica": "",
  "American Samoa": "+1-684",
  "Argentina": "54",
  "Australia": "61",
  "Austria": "43",
  "Aruba": "297",
  "India": "91",
  "Aland Islands": "+358-18",
  "Azerbaijan": "994",
  "Ireland": "353",
  "Indonesia": "62",
  "Ukraine": "380",
  "Qatar": "974",
  "Mozambique": "258"
};

// Add Button Options
const newConnectionText = 'New Connection';
const newPodText = 'New Pod';

const newEventText = 'New Event';
const newReminderText = 'New Reminder';

// Pod Objects

class Pod {
  Pod(
      {required this.name,
      required this.id,
      this.avatar,
      this.connectedContacts,
      this.unconnectedContacts});
  String name;
  String id;
  Uint8List? avatar;
  List<ConnectedContact>? connectedContacts;
  List<UnconnectedContact>? unconnectedContacts;
}

// Connection Objects
class ConnectedContact {
  ConnectedContact(
      {required this.name,
      required this.initials,
      this.avatar,
      required this.phone,
      this.location,
      required this.city,
      required this.street});
  String name;
  String initials;
  Uint8List? avatar;
  String phone;
  LatLng? location;
  String city = 'Not Available';
  String street = 'Not Available';
}

class UnconnectedContact {
  UnconnectedContact(
      {required this.name,
      required this.initials,
      this.avatar,
      required this.phone});
  String name;
  String initials;
  Uint8List? avatar;
  String phone;
}

class ContactsMap {
  ContactsMap({this.connected, this.unconnected});
  List<ConnectedContact>? connected;
  List<UnconnectedContact>? unconnected;
}

// Search Tags

class TagModel {
  String id;
  String title;
  Color tagColor;
  TagModel({required this.id, required this.title, required this.tagColor});
}

final List<TagModel> connectionTags = [
  TagModel(id: '1', title: 'Connections', tagColor: primaryColor),
  TagModel(id: '2', title: 'Pods', tagColor: primaryColor),
  TagModel(id: '3', title: 'Contacts', tagColor: primaryColor),
];
