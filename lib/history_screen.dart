import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Box historyBox = Hive.box('historyBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculation History")),
      body: historyBox.isEmpty
          ? Center(child: Text("No history yet"))
          : ListView.builder(
              itemCount: historyBox.length,
              itemBuilder: (context, index) {
                var history = historyBox.getAt(index);
                return ListTile(
                  leading: Icon(Icons.calculate, color: Colors.orange),
                  title: Text("${history["expression"]} = ${history["result"]}"),
                  subtitle: Text(history["time"]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        historyBox.deleteAt(index);
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
