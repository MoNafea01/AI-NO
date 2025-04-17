// import 'package:ai_gen/features/node_view/presentation/node_builder/custom_interfaces/vs_text_input_data.dart';
// import 'package:ai_gen/features/node_view/presentation/old_node_builder/old_apicalls/train_test_split.dart';
// import 'package:ai_gen/node_package/data/standard_interfaces/vs_list_interface.dart';
// import 'package:ai_gen/node_package/data/standard_interfaces/vs_map_interface.dart';
// import 'package:ai_gen/node_package/data/standard_interfaces/vs_model_interface.dart';
// import 'package:ai_gen/node_package/data/vs_interface.dart';
// import 'package:ai_gen/node_package/data/vs_subgroup.dart';
// import 'package:ai_gen/node_package/special_nodes/vs_widget_node.dart';
// import 'package:flutter/material.dart';
//
// class FunctionsSubgroup extends VSSubgroup {
//   FunctionsSubgroup()
//       : super(
//           name: "Functions",
//           subgroup: [
//             _trainTestSplit,
//             _fitModel,
//             _predict,
//             _fitPreprocessor,
//             _transform,
//           ],
//         );
//
//   static VSWidgetNode _fitPreprocessor(
//       Offset offset, VSOutputData<dynamic>? ref) {
//     return VSWidgetNode(
//       type: "Fit Preprocess",
//       widgetOffset: offset,
//       setValue: (value) {},
//       getValue: () => "",
//       inputData: [
//         VSOldModelInputData(
//           type: "data",
//           initialConnection: ref,
//         ),
//         VSMapInputData(
//           type: "preprocessor",
//           initialConnection: ref,
//         ),
//       ],
//       outputData: [
//         VSMapOutputData(
//           type: "Fitted data",
//           outputFunction: (data) async {
//             data["data"] = await data["data"];
//             Map<String, dynamic> predictions =
//                 await OldApiCall().fit_preprocessor(
//               data["data"],
//               data["preprocessor"],
//             );
//
//             return predictions;
//           },
//         ),
//       ],
//     );
//   }
//
//   static VSWidgetNode _transform(Offset offset, VSOutputData<dynamic>? ref) {
//     return VSWidgetNode(
//       type: "transform Preprocess",
//       widgetOffset: offset,
//       setValue: (value) {},
//       getValue: () => "",
//       inputData: [
//         VSOldModelInputData(
//           type: "data",
//           initialConnection: ref,
//         ),
//         VSMapInputData(
//           type: "preprocessor",
//           initialConnection: ref,
//         ),
//       ],
//       outputData: [
//         VSMapOutputData(
//           type: "transformed",
//           outputFunction: (data) async {
//             data["data"] = await data["data"];
//             Map<String, dynamic> predictions = await OldApiCall().transform(
//               data["data"],
//               data["preprocessor"],
//             );
//             return predictions;
//           },
//         ),
//       ],
//     );
//   }
//
//   static VSWidgetNode _predict(Offset offset, VSOutputData<dynamic>? ref) {
//     return VSWidgetNode(
//       type: "Predict",
//       widgetOffset: offset,
//       setValue: (value) {},
//       getValue: () => "",
//       inputData: [
//         VSOldModelInputData(
//           type: "Model",
//           initialConnection: ref,
//         ),
//         VSMapInputData(
//           type: "X",
//           initialConnection: ref,
//         ),
//       ],
//       outputData: [
//         VSMapOutputData(
//           type: "predictions",
//           outputFunction: (data) async {
//             data["Model"] = await data["Model"];
//             Map<String, dynamic> predictions = await OldApiCall().predict(
//               data["Model"],
//               data["X"],
//             );
//
//             return predictions;
//           },
//         ),
//       ],
//     );
//   }
//
//   static VSWidgetNode _fitModel(Offset offset, VSOutputData<dynamic>? ref) {
//     return VSWidgetNode(
//       type: "Fit Model",
//       widgetOffset: offset,
//       setValue: (value) {},
//       getValue: () => "",
//       inputData: [
//         VSOldModelInputData(
//           type: "Model",
//           initialConnection: ref,
//         ),
//         VSMapInputData(
//           type: "X",
//           initialConnection: ref,
//         ),
//         VSMapInputData(
//           type: "Y",
//           initialConnection: ref,
//         ),
//       ],
//       outputData: [
//         VSMapOutputData(
//           type: "Fitted Model",
//           outputFunction: (data) async {
//             print("Fitted Model $data");
//             data["Model"] = await data["Model"];
//             Map<String, dynamic> fittedModel = await OldApiCall().fitModel(
//               data["Model"],
//               data["X"],
//               data["Y"],
//             );
//
//             return fittedModel;
//           },
//         ),
//       ],
//     );
//   }
//
//   static VSWidgetNode _trainTestSplit(
//       Offset offset, VSOutputData<dynamic>? ref) {
//     Future<Map<String, dynamic>>? splitDataFuture;
//     final testSizeController = TextEditingController()..text = "0.5";
//     final randomStateController = TextEditingController()..text = "2";
//     return VSWidgetNode(
//       type: "train Test Split",
//       widgetOffset: offset,
//       setValue: (value) {},
//       getValue: () => "",
//       inputData: [
//         VSListInputData(
//           type: "data",
//           initialConnection: ref,
//         ),
//         VsTextInputData(
//           type: "test_size",
//           controller: testSizeController,
//         ),
//         VsTextInputData(
//           controller: randomStateController,
//           type: "random_state",
//         ),
//       ],
//       outputData: [
//         VSListOutputData(
//           type: "X_train",
//           outputFunction: (data) async {
//             data["data"] = await data["data"];
//             splitDataFuture = OldApiCall().trainTestSplit(
//               data["data"],
//               testSize: double.parse(testSizeController.text),
//               randomState: int.parse(randomStateController.text),
//             );
//             Map<String, dynamic> splitData = await splitDataFuture!;
//
//             return splitData['X_train']!;
//           },
//         ),
//         VSListOutputData(
//           type: "X_test",
//           outputFunction: (data) async {
//             data["data"] = await data["data"];
//
//             splitDataFuture ??= OldApiCall().trainTestSplit(data["data"]);
//
//             Map<String, dynamic> splitData = await splitDataFuture!;
//
//             return splitData['X_test']!;
//           },
//         ),
//       ],
//     );
//   }
// }
