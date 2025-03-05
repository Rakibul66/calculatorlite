import 'package:calculator/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('historyBox'); // Open Hive Box

  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812), // Standard responsive design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Calculator with History',
          theme: ThemeData.dark(),
          home: CalculatorScreen(),
        );
      },
    );
  }
}





class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _displayValue = "0";
  final Box historyBox = Hive.box('historyBox');

  void _onPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _displayValue = "0";
      } else if (value == "DEL") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == "=") {
        _evaluateExpression();
      } else {
        _expression += value;
      }
      _updateDisplayValue();
    });
  }

  void _updateDisplayValue() {
    setState(() {
      _displayValue = _expression.isEmpty ? "0" : _expression;
    });
  }

  void _evaluateExpression() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      String result = eval.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

      setState(() {
        _displayValue = result;
        _expression = result;
      });

      // Save calculation in history
      _saveHistory(_expression, result);
    } catch (e) {
      setState(() {
        _displayValue = "Error";
      });
    }
  }

  void _saveHistory(String expression, String result) {
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    historyBox.add({"expression": expression, "result": result, "time": formattedTime});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Area
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Text(
                _displayValue,
                style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // Buttons Area
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 1.2,
                children: [
                  _calcButton("C", Colors.redAccent),
                  _calcButton("DEL", Colors.grey),
                  _calcButton("/", Colors.orange),
                  _calcButton("*", Colors.orange),
                  _calcButton("7", Colors.grey.shade800),
                  _calcButton("8", Colors.grey.shade800),
                  _calcButton("9", Colors.grey.shade800),
                  _calcButton("-", Colors.orange),
                  _calcButton("4", Colors.grey.shade800),
                  _calcButton("5", Colors.grey.shade800),
                  _calcButton("6", Colors.grey.shade800),
                  _calcButton("+", Colors.orange),
                  _calcButton("1", Colors.grey.shade800),
                  _calcButton("2", Colors.grey.shade800),
                  _calcButton("3", Colors.grey.shade800),
                  _calcButton("=", Colors.green),
                  _calcButton("0", Colors.grey.shade800),
                  _calcButton(".", Colors.grey.shade800),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String text, Color color) {
    return GestureDetector(
      onTap: () => _onPressed(text),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
