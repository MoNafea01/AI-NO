part of 'home_cubit.dart';


sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeSuccess extends HomeState {
  final List<ProjectModel> projects;

  HomeSuccess({required this.projects});
}
final class HomeSearchEmpty extends HomeState {
  final String query;

  HomeSearchEmpty({required this.query});
}

final class HomeFailure extends HomeState {
  final String errMsg;

  HomeFailure({required this.errMsg});
}
