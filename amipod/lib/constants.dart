import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const primaryColor = Color.fromARGB(255, 29, 211, 176);
const whiteBackground = Color.fromARGB(255, 251, 254, 254);
const backgroundColor = Color(0xFF161F20);
const dipityPurple = Color(0xFF7E2E84);
const podOrange = Color(0xFFF97068);
const podOrangeOpp = Color.fromARGB(186, 249, 111, 104);

const dipityBlack = Color(0xFF22242F);
// Shared Preferences Keys
const firstNameKey = 'first_name';
const lastNameKey = 'last_name';
const loggedInKey = 'logged_in';
const isUnchartedModeKey = 'isUnchartedMode';

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

bool isNullEmptyOrFalse(dynamic o) {
  if (o is Map<String, dynamic> || o is List<dynamic>) {
    return o == null || o.length == 0;
  }
  return o == null || false == o || "" == o;
}

class Country {
  final String country;
  final Double code;

  Country({required this.country, required this.code});
}

List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

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

class Countries {
  static List<Map<String, String>> allCountries = [
    {"name": "Afghanistan", "dial_code": "+93", "code": "AF"},
    {"name": "Aland Islands", "dial_code": "+358", "code": "AX"},
    {"name": "Albania", "dial_code": "+355", "code": "AL"},
    {"name": "Algeria", "dial_code": "+213", "code": "DZ"},
    {"name": "AmericanSamoa", "dial_code": "+1684", "code": "AS"},
    {"name": "Andorra", "dial_code": "+376", "code": "AD"},
    {"name": "Angola", "dial_code": "+244", "code": "AO"},
    {"name": "Anguilla", "dial_code": "+1264", "code": "AI"},
    {"name": "Antarctica", "dial_code": "+672", "code": "AQ"},
    {"name": "Antigua and Barbuda", "dial_code": "+1268", "code": "AG"},
    {"name": "Argentina", "dial_code": "+54", "code": "AR"},
    {"name": "Armenia", "dial_code": "+374", "code": "AM"},
    {"name": "Aruba", "dial_code": "+297", "code": "AW"},
    {"name": "Australia", "dial_code": "+61", "code": "AU"},
    {"name": "Austria", "dial_code": "+43", "code": "AT"},
    {"name": "Azerbaijan", "dial_code": "+994", "code": "AZ"},
    {"name": "Bahamas", "dial_code": "+1242", "code": "BS"},
    {"name": "Bahrain", "dial_code": "+973", "code": "BH"},
    {"name": "Bangladesh", "dial_code": "+880", "code": "BD"},
    {"name": "Barbados", "dial_code": "+1246", "code": "BB"},
    {"name": "Belarus", "dial_code": "+375", "code": "BY"},
    {"name": "Belgium", "dial_code": "+32", "code": "BE"},
    {"name": "Belize", "dial_code": "+501", "code": "BZ"},
    {"name": "Benin", "dial_code": "+229", "code": "BJ"},
    {"name": "Bermuda", "dial_code": "+1441", "code": "BM"},
    {"name": "Bhutan", "dial_code": "+975", "code": "BT"},
    {
      "name": "Bolivia, Plurinational State of",
      "dial_code": "+591",
      "code": "BO"
    },
    {"name": "Bosnia and Herzegovina", "dial_code": "+387", "code": "BA"},
    {"name": "Botswana", "dial_code": "+267", "code": "BW"},
    {"name": "Brazil", "dial_code": "+55", "code": "BR"},
    {
      "name": "British Indian Ocean Territory",
      "dial_code": "+246",
      "code": "IO"
    },
    {"name": "Brunei Darussalam", "dial_code": "+673", "code": "BN"},
    {"name": "Bulgaria", "dial_code": "+359", "code": "BG"},
    {"name": "Burkina Faso", "dial_code": "+226", "code": "BF"},
    {"name": "Burundi", "dial_code": "+257", "code": "BI"},
    {"name": "Cambodia", "dial_code": "+855", "code": "KH"},
    {"name": "Cameroon", "dial_code": "+237", "code": "CM"},
    {"name": "Canada", "dial_code": "+1", "code": "CA"},
    {"name": "Cape Verde", "dial_code": "+238", "code": "CV"},
    {"name": "Cayman Islands", "dial_code": "+ 345", "code": "KY"},
    {"name": "Central African Republic", "dial_code": "+236", "code": "CF"},
    {"name": "Chad", "dial_code": "+235", "code": "TD"},
    {"name": "Chile", "dial_code": "+56", "code": "CL"},
    {"name": "China", "dial_code": "+86", "code": "CN"},
    {"name": "Christmas Island", "dial_code": "+61", "code": "CX"},
    {"name": "Cocos (Keeling) Islands", "dial_code": "+61", "code": "CC"},
    {"name": "Colombia", "dial_code": "+57", "code": "CO"},
    {"name": "Comoros", "dial_code": "+269", "code": "KM"},
    {"name": "Congo", "dial_code": "+242", "code": "CG"},
    {
      "name": "Congo, The Democratic Republic of the Congo",
      "dial_code": "+243",
      "code": "CD"
    },
    {"name": "Cook Islands", "dial_code": "+682", "code": "CK"},
    {"name": "Costa Rica", "dial_code": "+506", "code": "CR"},
    {"name": "Cote d'Ivoire", "dial_code": "+225", "code": "CI"},
    {"name": "Croatia", "dial_code": "+385", "code": "HR"},
    {"name": "Cuba", "dial_code": "+53", "code": "CU"},
    {"name": "Cyprus", "dial_code": "+357", "code": "CY"},
    {"name": "Czech Republic", "dial_code": "+420", "code": "CZ"},
    {"name": "Denmark", "dial_code": "+45", "code": "DK"},
    {"name": "Djibouti", "dial_code": "+253", "code": "DJ"},
    {"name": "Dominica", "dial_code": "+1767", "code": "DM"},
    {"name": "Dominican Republic", "dial_code": "+1849", "code": "DO"},
    {"name": "Ecuador", "dial_code": "+593", "code": "EC"},
    {"name": "Egypt", "dial_code": "+20", "code": "EG"},
    {"name": "El Salvador", "dial_code": "+503", "code": "SV"},
    {"name": "Equatorial Guinea", "dial_code": "+240", "code": "GQ"},
    {"name": "Eritrea", "dial_code": "+291", "code": "ER"},
    {"name": "Estonia", "dial_code": "+372", "code": "EE"},
    {"name": "Ethiopia", "dial_code": "+251", "code": "ET"},
    {"name": "Falkland Islands (Malvinas)", "dial_code": "+500", "code": "FK"},
    {"name": "Faroe Islands", "dial_code": "+298", "code": "FO"},
    {"name": "Fiji", "dial_code": "+679", "code": "FJ"},
    {"name": "Finland", "dial_code": "+358", "code": "FI"},
    {"name": "France", "dial_code": "+33", "code": "FR"},
    {"name": "French Guiana", "dial_code": "+594", "code": "GF"},
    {"name": "French Polynesia", "dial_code": "+689", "code": "PF"},
    {"name": "Gabon", "dial_code": "+241", "code": "GA"},
    {"name": "Gambia", "dial_code": "+220", "code": "GM"},
    {"name": "Georgia", "dial_code": "+995", "code": "GE"},
    {"name": "Germany", "dial_code": "+49", "code": "DE"},
    {"name": "Ghana", "dial_code": "+233", "code": "GH"},
    {"name": "Gibraltar", "dial_code": "+350", "code": "GI"},
    {"name": "Greece", "dial_code": "+30", "code": "GR"},
    {"name": "Greenland", "dial_code": "+299", "code": "GL"},
    {"name": "Grenada", "dial_code": "+1473", "code": "GD"},
    {"name": "Guadeloupe", "dial_code": "+590", "code": "GP"},
    {"name": "Guam", "dial_code": "+1671", "code": "GU"},
    {"name": "Guatemala", "dial_code": "+502", "code": "GT"},
    {"name": "Guernsey", "dial_code": "+44", "code": "GG"},
    {"name": "Guinea", "dial_code": "+224", "code": "GN"},
    {"name": "Guinea-Bissau", "dial_code": "+245", "code": "GW"},
    {"name": "Guyana", "dial_code": "+595", "code": "GY"},
    {"name": "Haiti", "dial_code": "+509", "code": "HT"},
    {
      "name": "Holy See (Vatican City State)",
      "dial_code": "+379",
      "code": "VA"
    },
    {"name": "Honduras", "dial_code": "+504", "code": "HN"},
    {"name": "Hong Kong", "dial_code": "+852", "code": "HK"},
    {"name": "Hungary", "dial_code": "+36", "code": "HU"},
    {"name": "Iceland", "dial_code": "+354", "code": "IS"},
    {"name": "India", "dial_code": "+91", "code": "IN"},
    {"name": "Indonesia", "dial_code": "+62", "code": "ID"},
    {
      "name": "Iran, Islamic Republic of Persian Gulf",
      "dial_code": "+98",
      "code": "IR"
    },
    {"name": "Iraq", "dial_code": "+964", "code": "IQ"},
    {"name": "Ireland", "dial_code": "+353", "code": "IE"},
    {"name": "Isle of Man", "dial_code": "+44", "code": "IM"},
    {"name": "Israel", "dial_code": "+972", "code": "IL"},
    {"name": "Italy", "dial_code": "+39", "code": "IT"},
    {"name": "Jamaica", "dial_code": "+1876", "code": "JM"},
    {"name": "Japan", "dial_code": "+81", "code": "JP"},
    {"name": "Jersey", "dial_code": "+44", "code": "JE"},
    {"name": "Jordan", "dial_code": "+962", "code": "JO"},
    {"name": "Kazakhstan", "dial_code": "+77", "code": "KZ"},
    {"name": "Kenya", "dial_code": "+254", "code": "KE"},
    {"name": "Kiribati", "dial_code": "+686", "code": "KI"},
    {
      "name": "Korea, Democratic People's Republic of Korea",
      "dial_code": "+850",
      "code": "KP"
    },
    {
      "name": "Korea, Republic of South Korea",
      "dial_code": "+82",
      "code": "KR"
    },
    {"name": "Kuwait", "dial_code": "+965", "code": "KW"},
    {"name": "Kyrgyzstan", "dial_code": "+996", "code": "KG"},
    {"name": "Laos", "dial_code": "+856", "code": "LA"},
    {"name": "Latvia", "dial_code": "+371", "code": "LV"},
    {"name": "Lebanon", "dial_code": "+961", "code": "LB"},
    {"name": "Lesotho", "dial_code": "+266", "code": "LS"},
    {"name": "Liberia", "dial_code": "+231", "code": "LR"},
    {"name": "Libyan Arab Jamahiriya", "dial_code": "+218", "code": "LY"},
    {"name": "Liechtenstein", "dial_code": "+423", "code": "LI"},
    {"name": "Lithuania", "dial_code": "+370", "code": "LT"},
    {"name": "Luxembourg", "dial_code": "+352", "code": "LU"},
    {"name": "Macao", "dial_code": "+853", "code": "MO"},
    {"name": "Macedonia", "dial_code": "+389", "code": "MK"},
    {"name": "Madagascar", "dial_code": "+261", "code": "MG"},
    {"name": "Malawi", "dial_code": "+265", "code": "MW"},
    {"name": "Malaysia", "dial_code": "+60", "code": "MY"},
    {"name": "Maldives", "dial_code": "+960", "code": "MV"},
    {"name": "Mali", "dial_code": "+223", "code": "ML"},
    {"name": "Malta", "dial_code": "+356", "code": "MT"},
    {"name": "Marshall Islands", "dial_code": "+692", "code": "MH"},
    {"name": "Martinique", "dial_code": "+596", "code": "MQ"},
    {"name": "Mauritania", "dial_code": "+222", "code": "MR"},
    {"name": "Mauritius", "dial_code": "+230", "code": "MU"},
    {"name": "Mayotte", "dial_code": "+262", "code": "YT"},
    {"name": "Mexico", "dial_code": "+52", "code": "MX"},
    {
      "name": "Micronesia, Federated States of Micronesia",
      "dial_code": "+691",
      "code": "FM"
    },
    {"name": "Moldova", "dial_code": "+373", "code": "MD"},
    {"name": "Monaco", "dial_code": "+377", "code": "MC"},
    {"name": "Mongolia", "dial_code": "+976", "code": "MN"},
    {"name": "Montenegro", "dial_code": "+382", "code": "ME"},
    {"name": "Montserrat", "dial_code": "+1664", "code": "MS"},
    {"name": "Morocco", "dial_code": "+212", "code": "MA"},
    {"name": "Mozambique", "dial_code": "+258", "code": "MZ"},
    {"name": "Myanmar", "dial_code": "+95", "code": "MM"},
    {"name": "Namibia", "dial_code": "+264", "code": "NA"},
    {"name": "Nauru", "dial_code": "+674", "code": "NR"},
    {"name": "Nepal", "dial_code": "+977", "code": "NP"},
    {"name": "Netherlands", "dial_code": "+31", "code": "NL"},
    {"name": "Netherlands Antilles", "dial_code": "+599", "code": "AN"},
    {"name": "New Caledonia", "dial_code": "+687", "code": "NC"},
    {"name": "New Zealand", "dial_code": "+64", "code": "NZ"},
    {"name": "Nicaragua", "dial_code": "+505", "code": "NI"},
    {"name": "Niger", "dial_code": "+227", "code": "NE"},
    {"name": "Nigeria", "dial_code": "+234", "code": "NG"},
    {"name": "Niue", "dial_code": "+683", "code": "NU"},
    {"name": "Norfolk Island", "dial_code": "+672", "code": "NF"},
    {"name": "Northern Mariana Islands", "dial_code": "+1670", "code": "MP"},
    {"name": "Norway", "dial_code": "+47", "code": "NO"},
    {"name": "Oman", "dial_code": "+968", "code": "OM"},
    {"name": "Pakistan", "dial_code": "+92", "code": "PK"},
    {"name": "Palau", "dial_code": "+680", "code": "PW"},
    {
      "name": "Palestinian Territory, Occupied",
      "dial_code": "+970",
      "code": "PS"
    },
    {"name": "Panama", "dial_code": "+507", "code": "PA"},
    {"name": "Papua New Guinea", "dial_code": "+675", "code": "PG"},
    {"name": "Paraguay", "dial_code": "+595", "code": "PY"},
    {"name": "Peru", "dial_code": "+51", "code": "PE"},
    {"name": "Philippines", "dial_code": "+63", "code": "PH"},
    {"name": "Pitcairn", "dial_code": "+872", "code": "PN"},
    {"name": "Poland", "dial_code": "+48", "code": "PL"},
    {"name": "Portugal", "dial_code": "+351", "code": "PT"},
    {"name": "Puerto Rico", "dial_code": "+1939", "code": "PR"},
    {"name": "Qatar", "dial_code": "+974", "code": "QA"},
    {"name": "Romania", "dial_code": "+40", "code": "RO"},
    {"name": "Russia", "dial_code": "+7", "code": "RU"},
    {"name": "Rwanda", "dial_code": "+250", "code": "RW"},
    {"name": "Reunion", "dial_code": "+262", "code": "RE"},
    {"name": "Saint Barthelemy", "dial_code": "+590", "code": "BL"},
    {
      "name": "Saint Helena, Ascension and Tristan Da Cunha",
      "dial_code": "+290",
      "code": "SH"
    },
    {"name": "Saint Kitts and Nevis", "dial_code": "+1869", "code": "KN"},
    {"name": "Saint Lucia", "dial_code": "+1758", "code": "LC"},
    {"name": "Saint Martin", "dial_code": "+590", "code": "MF"},
    {"name": "Saint Pierre and Miquelon", "dial_code": "+508", "code": "PM"},
    {
      "name": "Saint Vincent and the Grenadines",
      "dial_code": "+1784",
      "code": "VC"
    },
    {"name": "Samoa", "dial_code": "+685", "code": "WS"},
    {"name": "San Marino", "dial_code": "+378", "code": "SM"},
    {"name": "Sao Tome and Principe", "dial_code": "+239", "code": "ST"},
    {"name": "Saudi Arabia", "dial_code": "+966", "code": "SA"},
    {"name": "Senegal", "dial_code": "+221", "code": "SN"},
    {"name": "Serbia", "dial_code": "+381", "code": "RS"},
    {"name": "Seychelles", "dial_code": "+248", "code": "SC"},
    {"name": "Sierra Leone", "dial_code": "+232", "code": "SL"},
    {"name": "Singapore", "dial_code": "+65", "code": "SG"},
    {"name": "Slovakia", "dial_code": "+421", "code": "SK"},
    {"name": "Slovenia", "dial_code": "+386", "code": "SI"},
    {"name": "Solomon Islands", "dial_code": "+677", "code": "SB"},
    {"name": "Somalia", "dial_code": "+252", "code": "SO"},
    {"name": "South Africa", "dial_code": "+27", "code": "ZA"},
    {"name": "South Sudan", "dial_code": "+211", "code": "SS"},
    {
      "name": "South Georgia and the South Sandwich Islands",
      "dial_code": "+500",
      "code": "GS"
    },
    {"name": "Spain", "dial_code": "+34", "code": "ES"},
    {"name": "Sri Lanka", "dial_code": "+94", "code": "LK"},
    {"name": "Sudan", "dial_code": "+249", "code": "SD"},
    {"name": "Suriname", "dial_code": "+597", "code": "SR"},
    {"name": "Svalbard and Jan Mayen", "dial_code": "+47", "code": "SJ"},
    {"name": "Swaziland", "dial_code": "+268", "code": "SZ"},
    {"name": "Sweden", "dial_code": "+46", "code": "SE"},
    {"name": "Switzerland", "dial_code": "+41", "code": "CH"},
    {"name": "Syrian Arab Republic", "dial_code": "+963", "code": "SY"},
    {"name": "Taiwan", "dial_code": "+886", "code": "TW"},
    {"name": "Tajikistan", "dial_code": "+992", "code": "TJ"},
    {
      "name": "Tanzania, United Republic of Tanzania",
      "dial_code": "+255",
      "code": "TZ"
    },
    {"name": "Thailand", "dial_code": "+66", "code": "TH"},
    {"name": "Timor-Leste", "dial_code": "+670", "code": "TL"},
    {"name": "Togo", "dial_code": "+228", "code": "TG"},
    {"name": "Tokelau", "dial_code": "+690", "code": "TK"},
    {"name": "Tonga", "dial_code": "+676", "code": "TO"},
    {"name": "Trinidad and Tobago", "dial_code": "+1868", "code": "TT"},
    {"name": "Tunisia", "dial_code": "+216", "code": "TN"},
    {"name": "Turkey", "dial_code": "+90", "code": "TR"},
    {"name": "Turkmenistan", "dial_code": "+993", "code": "TM"},
    {"name": "Turks and Caicos Islands", "dial_code": "+1649", "code": "TC"},
    {"name": "Tuvalu", "dial_code": "+688", "code": "TV"},
    {"name": "Uganda", "dial_code": "+256", "code": "UG"},
    {"name": "Ukraine", "dial_code": "+380", "code": "UA"},
    {"name": "United Arab Emirates", "dial_code": "+971", "code": "AE"},
    {"name": "United Kingdom", "dial_code": "+44", "code": "GB"},
    {"name": "United States", "dial_code": "+1", "code": "US"},
    {"name": "Uruguay", "dial_code": "+598", "code": "UY"},
    {"name": "Uzbekistan", "dial_code": "+998", "code": "UZ"},
    {"name": "Vanuatu", "dial_code": "+678", "code": "VU"},
    {
      "name": "Venezuela, Bolivarian Republic of Venezuela",
      "dial_code": "+58",
      "code": "VE"
    },
    {"name": "Vietnam", "dial_code": "+84", "code": "VN"},
    {"name": "Virgin Islands, British", "dial_code": "+1284", "code": "VG"},
    {"name": "Virgin Islands, U.S.", "dial_code": "+1340", "code": "VI"},
    {"name": "Wallis and Futuna", "dial_code": "+681", "code": "WF"},
    {"name": "Yemen", "dial_code": "+967", "code": "YE"},
    {"name": "Zambia", "dial_code": "+260", "code": "ZM"},
    {"name": "Zimbabwe", "dial_code": "+263", "code": "ZW"}
  ];
}

// Add Button Options
const newConnectionText = 'New Connection';
const newPodText = 'New Pod';

const newEventText = 'New Event';
const newReminderText = 'New Check-in';

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
      required this.street,
      this.last_update,
      required this.blocked,
      required this.uncharted});
  String name;
  String initials;
  Uint8List? avatar;
  String phone;
  LatLng? location;
  String city = 'Not Available';
  String street = 'Not Available';
  String? last_update;
  bool blocked = false;
  bool uncharted = false;
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
