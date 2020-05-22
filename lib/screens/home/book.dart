import 'package:flutter/material.dart';

class Book extends StatelessWidget {
  final int index;

  final arr = ["first", "second"];

  Book(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.amber),
      child: Text(arr[index]),
    );
  }
}
