



import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// class GridState extends Equatable {
//   final bool showGrid;
//   final double gridSpacing;

//   const GridState({required this.showGrid, required this.gridSpacing});

//   GridState copyWith({bool? showGrid, double? gridSpacing}) {
//     return GridState(
//       showGrid: showGrid ?? this.showGrid,
//       gridSpacing: gridSpacing ?? this.gridSpacing,
//     );
//   }

//   @override
//   List<Object> get props => [showGrid, gridSpacing];
// }

// class GridCubit extends Cubit<GridState> {
//   GridCubit() : super(const GridState(showGrid: false, gridSpacing: 20.0));

//   void toggleGrid() {
//     emit(state.copyWith(showGrid: !state.showGrid));
//   }

//   void updateGridSpacing(double spacing) {
//     emit(state.copyWith(gridSpacing: spacing));
//   }
// }

////////////////////////////////////////////////////////////////////////////////////////////////








// import 'package:flutter_bloc/flutter_bloc.dart';


// /// Cubit to manage grid state
// class GridCubit extends Cubit<GridState> {
//   GridCubit() : super(GridState());

//   void toggleGrid() {
//     emit(state.copyWith(showGrid: !state.showGrid));
//   }

//   void updateSpacing(double spacing) {
//     emit(state.copyWith(gridSpacing: spacing));
//   }

//   void updateColor(Color color) {
//     emit(state.copyWith(gridColor: color));
//   }
// }

// /// State for the grid
// class GridState {
//   final bool showGrid;
//   final double gridSpacing;
//   final Color gridColor;

//   GridState({this.showGrid = false, this.gridSpacing = 20.0, this.gridColor = Colors.grey});

//   GridState copyWith({bool? showGrid, double? gridSpacing, Color? gridColor}) {
//     return GridState(
//       showGrid: showGrid ?? this.showGrid,
//       gridSpacing: gridSpacing ?? this.gridSpacing,
//       gridColor: gridColor ?? this.gridColor,
//     );
//   }
// }


/// Cubit to manage grid state
// class GridCubit extends Cubit<GridState> {
//   GridCubit() : super(GridState());

//   void toggleGrid() => emit(state.copyWith(showGrid: !state.showGrid));
//   void updateSpacing(double spacing) => emit(state.copyWith(gridSpacing: spacing));
//   void updateColor(Color color) => emit(state.copyWith(gridColor: color));
// }

// /// State for the grid
// class GridState {
//   final bool showGrid;
//   final double gridSpacing;
//   final Color gridColor;

//   GridState({this.showGrid = false, this.gridSpacing = 20.0, this.gridColor = Colors.grey});

//   GridState copyWith({bool? showGrid, double? gridSpacing, Color? gridColor}) {
//     return GridState(
//       showGrid: showGrid ?? this.showGrid,
//       gridSpacing: gridSpacing ?? this.gridSpacing,
//       gridColor: gridColor ?? this.gridColor,
//     );
//   }
// }


// for zoom


/// Cubit to manage grid and zoom state
class GridCubit extends Cubit<GridState> {
  GridCubit() : super(GridState());

  void toggleGrid() => emit(state.copyWith(showGrid: !state.showGrid));
  void updateSpacing(double spacing) => emit(state.copyWith(gridSpacing: spacing));
  void updateColor(Color color) => emit(state.copyWith(gridColor: color));
  void updateZoom(double zoomLevel) => emit(state.copyWith(zoomLevel: zoomLevel));
  void toggleColorPicker() => emit(state.copyWith(showColorPicker: !state.showColorPicker));
}

class GridState {
  final bool showGrid;
  final double gridSpacing;
  final Color gridColor;
  final double zoomLevel;
  final bool showColorPicker;

  GridState({
    this.showGrid = false,
    this.gridSpacing = 20.0,
    this.gridColor = Colors.grey,
    this.zoomLevel = 1.0,
    this.showColorPicker = false,
  });

  GridState copyWith({
    bool? showGrid,
    double? gridSpacing,
    Color? gridColor,
    double? zoomLevel,
    bool? showColorPicker,
  }) {
    return GridState(
      showGrid: showGrid ?? this.showGrid,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      gridColor: gridColor ?? this.gridColor,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      showColorPicker: showColorPicker ?? this.showColorPicker,
    );
  }
}

