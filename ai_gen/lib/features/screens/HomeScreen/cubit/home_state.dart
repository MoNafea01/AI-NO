part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeSuccess extends HomeState {
  final List<ProjectModel> projects;

  HomeSuccess({required this.projects});
}

final class HomeFailure extends HomeState {
  final String errMsg;

  HomeFailure({required this.errMsg});
}
