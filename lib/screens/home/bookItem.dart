import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookItem extends StatefulWidget {
  final bookId;
  final todoCollectionRef;

  BookItem(this.bookId, this.todoCollectionRef);

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem>
    with AutomaticKeepAliveClientMixin<BookItem> {
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
    super.build(context);

    return Container(
      padding: EdgeInsets.only(left: 15, right: 13, top: 5),
      child: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              // PageItem(pages[index].data["page_name"], pages[index].documentID,
              //     pageRef, 0),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  _fetchPages() {
    pageRef =
        widget.todoCollectionRef.document(widget.bookId).collection("Pages");

    pageRefSnapshot =
        pageRef.orderBy('creation_date').snapshots().listen((data) {
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
