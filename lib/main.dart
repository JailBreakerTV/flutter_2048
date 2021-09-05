import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swipe/swipe.dart';

void main() {
  runApp(NumericGameApp());
}

const kLightTextColor = Color.fromARGB(255, 255, 255, 255);
const kDarkTextColor = Color.fromARGB(255, 117, 110, 102);
const kGridBackgroundColor = Color.fromARGB(255, 184, 173, 161);
const kBackgroundColor = Color.fromARGB(255, 250, 248, 240);
const kEmptyFieldColor = Color.fromARGB(255, 202, 192, 181);

const k2Color = Color.fromARGB(255, 236, 228, 219);
const k4Color = Color.fromARGB(255, 235, 224, 202);
const k8Color = Color.fromARGB(255, 232, 179, 129);
const k16Color = Color.fromARGB(255, 223, 145, 95);
const k32Color = Color.fromARGB(255, 230, 130, 102);
const k64Color = Color.fromARGB(255, 217, 98, 67);
const k128Color = Color.fromARGB(255, 238, 217, 123);
const kBigNumberColor = Color.fromARGB(255, 229, 197, 66);

class NumericGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final List<Cell> _values;
  late final Random random;

  @override
  void initState() {
    _values = List.unmodifiable(
      [
        //First Column
        Cell(0, 0, 0),
        Cell(1, 0, 0),
        Cell(2, 0, 4),
        Cell(3, 0, 0),
        //Second Column
        Cell(0, 1, 0),
        Cell(1, 1, 2),
        Cell(2, 1, 0),
        Cell(3, 1, 0),
        //Third Column
        Cell(0, 2, 0),
        Cell(1, 2, 0),
        Cell(2, 2, 0),
        Cell(3, 2, 0),
        //Fourth Column
        Cell(0, 3, 0),
        Cell(1, 3, 0),
        Cell(2, 3, 2),
        Cell(3, 3, 0),
      ],
    );
    random = Random();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: kBackgroundColor,
        child: Center(
          child: Swipe(
            onSwipeUp: _up,
            onSwipeDown: _down,
            onSwipeLeft: _left,
            onSwipeRight: _right,
            verticalMinDisplacement: 50,
            verticalMinVelocity: 150,
            horizontalMinDisplacement: 50,
            horizontalMinVelocity: 150,
            child: Container(
              height: 350,
              width: 350,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kGridBackgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                children:
                    _values.map((cell) => CellWidget(cell: cell)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Cell _findCell(int x, int y) {
    return _values.firstWhere((element) => element.x == x && element.y == y);
  }

  void moveCellVertical(Cell cell, bool up, Supplier<bool> moved) {
    if (cell.isEmpty()) {
      return;
    }
    if (up && cell.isFirstRow()) {
      return;
    }
    if (!up && cell.isLastRow()) {
      return;
    }
    final Cell next = _findCell(cell.x, up ? cell.y - 1 : cell.y + 1);
    if (next.isEmpty()) {
      next.value = cell.value;
      cell.value = 0;
      moved.value = true;
    } else {
      if (next.value == cell.value) {
        next.value = cell.value + next.value;
        cell.value = 0;
        moved.value = true;
      }
    }
    moveCellVertical(next, up, moved);
  }

  void moveCellHorizontal(Cell cell, bool right, Supplier<bool> moved) {
    if (cell.isEmpty()) {
      return;
    }
    if (right && cell.isRightBorder()) {
      return;
    }
    if (!right && cell.isLeftBorder()) {
      return;
    }
    final Cell next = _findCell(right ? cell.x + 1 : cell.x - 1, cell.y);
    if (next.isEmpty()) {
      next.value = cell.value;
      cell.value = 0;
      moved.value = true;
    } else {
      if (next.value == cell.value) {
        next.value = cell.value + next.value;
        cell.value = 0;
        moved.value = true;
      }
    }
    moveCellHorizontal(next, right, moved);
  }

  void _up() {
    final Supplier<bool> moved = Supplier(false);
    _values.forEach((element) => moveCellVertical(element, true, moved));
    if (moved.value) {
      _addRandomCell();
    }
    setState(() {});
  }

  void _down() {
    final Supplier<bool> moved = Supplier(false);
    _values.forEach((element) => moveCellVertical(element, false, moved));
    if (moved.value) {
      _addRandomCell();
    }
    setState(() {});
  }

  void _right() {
    final Supplier<bool> moved = Supplier(false);
    _values.forEach((element) => moveCellHorizontal(element, true, moved));
    if (moved.value) {
      _addRandomCell();
    }
    setState(() {});
  }

  void _left() {
    final Supplier<bool> moved = Supplier(false);
    _values.forEach((element) => moveCellHorizontal(element, false, moved));
    if (moved.value) {
      _addRandomCell();
    }
    setState(() {});
  }

  void _addRandomCell() {
    final Cell? empty = _findRandomEmptyCell();
    if (empty == null) {
      print("Verloren");
      return;
    }
    empty.value = random.nextInt(6).isEven ? 2 : 4;
  }

  Cell? _findRandomEmptyCell() {
    final List<Cell> cells = _values.where((cell) => cell.isEmpty()).toList();
    if (cells.isEmpty) {
      return null;
    }
    return cells[random.nextInt(cells.length)];
  }
}

class Cell {
  int x;
  int y;
  int value;

  Cell(this.x, this.y, this.value);

  bool isEmpty() => value == 0;
  bool isFirstRow() => y == 0;
  bool isLastRow() => y == 3;
  bool isLeftBorder() => x == 0;
  bool isRightBorder() => x == 3;

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class CellWidget extends StatelessWidget {
  final Cell cell;

  const CellWidget({
    Key? key,
    required this.cell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: cell.isEmpty() ? kEmptyFieldColor : cell.color(),
      ),
      child: cell.isEmpty()
          ? null
          : Center(
              child: Text(
                cell.value.toString(),
                style: TextStyle(
                  fontSize: 25,
                  color: cell.textColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

extension CellColor on Cell {
  Color color() {
    switch (value) {
      case 2:
        return k2Color;
      case 4:
        return k4Color;
      case 8:
        return k8Color;
      case 16:
        return k16Color;
      case 32:
        return k32Color;
      case 64:
        return k64Color;
      case 128:
        return k128Color;
      default:
        return kBigNumberColor;
    }
  }

  Color textColor() =>
      (value == 2 || value == 4) ? kDarkTextColor : kLightTextColor;
}

class Supplier<T> {
  T value;
  Supplier(this.value);
}
