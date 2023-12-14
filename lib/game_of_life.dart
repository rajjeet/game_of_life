import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Coordinates extends Equatable {
  const Coordinates({required this.x, required this.y});

  final int x;
  final int y;

  @override
  List<int> get props => [x, y];

  Coordinates getTop() => Coordinates(x: x, y: y - 1);

  Coordinates getTopLeft() => Coordinates(x: x - 1, y: y - 1);

  Coordinates getLeft() => Coordinates(x: x - 1, y: y);

  Coordinates getBottomLeft() => Coordinates(x: x - 1, y: y + 1);

  Coordinates getBottom() => Coordinates(x: x, y: y + 1);

  Coordinates getBottomRight() => Coordinates(x: x + 1, y: y + 1);

  Coordinates getRight() => Coordinates(x: x + 1, y: y);

  Coordinates getTopRight() => Coordinates(x: x + 1, y: y - 1);
}

class Board {
  Map<Coordinates, bool> cells;
  final int width;
  final int height;

  Board._internal(
      {required this.cells, required this.width, required this.height});

  factory Board.fromDimensions(int width, int height) {
    var cells = <Coordinates, bool>{};
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        var coordinates = Coordinates(x: x, y: y);
        cells[coordinates] = false;
      }
    }
    return Board._internal(cells: cells, width: width, height: height);
  }

  factory Board.fromPrevious(Board previous) {
    var newCells = <Coordinates, bool>{};
    var previousCells = previous.cells;
    previousCells.forEach((coordinates, isAlive) {
      var isTop = previousCells[coordinates.getTop()];
      var isTopLeft = previousCells[coordinates.getTopLeft()];
      var isLeft = previousCells[coordinates.getLeft()];
      var isBottomLeft = previousCells[coordinates.getBottomLeft()];
      var isBottom = previousCells[coordinates.getBottom()];
      var isBottomRight = previousCells[coordinates.getBottomRight()];
      var isRight = previousCells[coordinates.getRight()];
      var isTopRight = previousCells[coordinates.getTopRight()];
      var aliveNeighbours = [
        isTop,
        isTopLeft,
        isLeft,
        isBottomLeft,
        isBottom,
        isBottomRight,
        isRight,
        isTopRight
      ]
          .map((e) => e == true ? 1 : 0)
          .reduce((value, element) => value + element);
      // if (isAlive){
      //   debugPrint('$coordinates isTop:$isTop, isTopLeft:$isTopLeft, isLeft:$isLeft, '
      //       'isBottomLeft: $isBottomLeft, isBottom: $isBottom, '
      //       'isBottomRight: $isBottomRight, isRight: $isRight, '
      //       'isTopRight: $isTopRight');
      // }
      if (isAlive && (aliveNeighbours > 1 && aliveNeighbours < 4)) {
        newCells[coordinates] = true;
      } else if (!isAlive && aliveNeighbours == 3) {
        newCells[coordinates] = true;
      } else {
        newCells[coordinates] = false;
      }
    });
    return Board._internal(
        cells: newCells, width: previous.width, height: previous.height);
  }
}

class GameOfLife extends StatefulWidget {
  GameOfLife({super.key, required this.board});

  Board board;

  @override
  State<GameOfLife> createState() => _GameOfLifeState();
}

class _GameOfLifeState extends State<GameOfLife> {
  bool isRunning = false;
  Timer? timer;
  int cycleCount = 0;
  int timerInterval = 1000;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildBoard(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildTimerIntervalButton(interval: 100),
            buildTimerIntervalButton(interval: 200),
            buildTimerIntervalButton(interval: 500),
            buildTimerIntervalButton(interval: 1000)
          ],
        ),
        buildCycleDisplay(),
        buildStartStopButton()
      ],
    );
  }

  Expanded buildBoard() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: widget.board.width,
        children:
            List.generate(widget.board.height * widget.board.width, (index) {
          var xGrid = (index % widget.board.width);
          var yGrid = (index / widget.board.width).floor();
          var gestureDetector = GestureDetector(
            onTap: () {
              setState(() {
                widget.board.cells[Coordinates(x: xGrid, y: yGrid)] =
                    !widget.board.cells[Coordinates(x: xGrid, y: yGrid)]!;
              });
            },
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.white),
                color:
                    widget.board.cells[Coordinates(x: xGrid, y: yGrid)] == true
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          );
          return gestureDetector;
        }),
      ),
    );
  }

  Padding buildCycleDisplay() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text('Cycles: $cycleCount',
          style: const TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  ElevatedButton buildStartStopButton() {
    return ElevatedButton(
        onPressed: () {
          if (isRunning) {
            timer?.cancel();
            setState(() {
              isRunning = false;
            });
          } else {
            timer?.cancel();
            timer = setTimer();
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: isRunning ? Colors.red : Colors.green,
            foregroundColor: Colors.white),
        child: Text(
          isRunning ? 'STOP' : 'START',
        ));
  }

  Timer setTimer() {
    return Timer.periodic(Duration(milliseconds: timerInterval), (timer) {
            setState(() {
              cycleCount++;
              widget.board = Board.fromPrevious(widget.board);
              isRunning = true;
            });
          });
  }

  ElevatedButton buildTimerIntervalButton({required int interval}) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor:
                timerInterval == interval ? Colors.amber : Colors.white,
            foregroundColor:
                timerInterval == interval ? Colors.black : Colors.black),
        onPressed: () {
          setState(() {
            timerInterval = interval;
            timer?.cancel();
            timer = setTimer();
          });
        },
        child: Text('$interval ms'));
  }
}
