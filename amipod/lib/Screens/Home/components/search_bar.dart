import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<dynamic> contacts;
  final Iterable<dynamic> connections;
  final Iterable<dynamic> pods;

  CustomSearchDelegate(this.contacts, this.connections, this.pods);

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> matchQuery = [];
    for (var contact in contacts) {
      if (contact.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(contact);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result.name),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> matchQuery = [];
    for (var contact in contacts) {
      if (contact.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(contact);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result.name),
        );
      },
    );
  }
}
