import 'dart:math';

enum OPERATOR { add, subtract }

class Operation {
  late int firstNumber;
  late int secondNumber;
  late OPERATOR operator;

  Operation(int limit) {
    operator = Random().nextBool() ? OPERATOR.add : OPERATOR.subtract;
    List<int> numbers = [
      Random().nextInt(limit) + 1,
      Random().nextInt(limit) + 1
    ];
    if (operator == OPERATOR.subtract) numbers.sort((a, b) => b.compareTo(a));
    firstNumber = numbers[0];
    secondNumber = numbers[1];
  }

  int get result => (operator == OPERATOR.add)
      ? firstNumber + secondNumber
      : firstNumber - secondNumber;

  String get operatorAsString => (operator == OPERATOR.add) ? '+' : '-';

  bool isCorrect(n) => result == n;

  @override
  String toString() {
    return 'Operation{$firstNumber $operator $secondNumber}';
  }
}
