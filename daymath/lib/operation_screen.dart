import 'package:daymath/operation.dart';
import 'package:flutter/material.dart';

class OperationScreen extends StatefulWidget {
  final int limit;

  OperationScreen(this.limit);

  @override
  State<OperationScreen> createState() => _OperationScreenState(limit);
}

class _OperationScreenState extends State<OperationScreen> {
  Operation? operation;
  int? result;
  bool correct = false;
  final int limit;

  _OperationScreenState(this.limit);

  @override
  void initState() {
    super.initState();
    operation = Operation(limit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 5,
        title: Text('Operaciones', style: TextStyle(color: Colors.white)),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${operation!.firstNumber}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${operation!.operatorAsString}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      '${operation!.secondNumber}',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: correct ? Colors.green : Colors.grey,
                        width: 3,
                      ),
                    ),
                    child: Text(
                      result != null ? '${result}' : '',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: correct
                    ? Icon(Icons.check_circle, color: Colors.green, size: 50)
                    : Container(),
              ),
            ),
            Row(
              children: [7, 8, 9].map((n) => numberKey(n)).toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [4, 5, 6].map((n) => numberKey(n)).toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [1, 2, 3].map((n) => numberKey(n)).toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [0, null].map((n) => numberKey(n)).toList(),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void clearResult() => setState(() => result = null);

  void newNumber(n) {
    if (correct) return;
    if (n == null) setState(() => result = null);

    String resultAsString = result != null ? '$result' : '';
    resultAsString += '$n';
    setState(() => result = int.parse(resultAsString));
    if (operation!.isCorrect(result)) {
      setState(() => correct = true);
      Future.delayed(Duration(milliseconds: 700)).then((_) {
        setState(() {
          correct = false;
          result = null;
          operation = Operation(limit);
        });
      });
    }
  }

  Widget numberKey(int? n) {
    // n == null => delete button
    return Expanded(
      flex: n != 0 ? 1 : 2,
      child: InkWell(
        onTap: () => n != null ? newNumber(n) : clearResult(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.08,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red,
            gradient: LinearGradient(
              colors: [Colors.red, Colors.red[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white),
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: n != null
                  ? Text(
                      '$n',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
