import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jots_mobile/screens/home/pageItem.dart';
import 'package:jots_mobile/theme.dart' as Theme;

class BookItem extends StatefulWidget {
  final bookId;
  final todoCollectionRef;

  BookItem(this.bookId, this.todoCollectionRef);

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  List pages = [];
  CollectionReference pageRef;
  StreamSubscription<QuerySnapshot> pageRefSnapshot;

  @override
  void initState() {
    super.initState();

    _fetchPages();
  }

  @override
  void dispose() {
    super.dispose();

    pageRefSnapshot.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 13, top: 5),
      child: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              // page name
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 13),
                alignment: Alignment.centerLeft,
                child: Text(
                  pages[index].data["page_name"],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.darkTextColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PageItem(pages[index].documentID, pageRef),
            ],
          );
        },
      ),
    );
  }

  _fetchPages() {
    pageRef =
        widget.todoCollectionRef.document(widget.bookId).collection("Pages");

    pageRefSnapshot = pageRef.snapshots().listen((data) {
      List fetchedpages = [];

      data.documents.forEach((doc) {
        fetchedpages.add(doc);
      });

      setState(() {
        pages = fetchedpages;
      });
    });
  }
}
