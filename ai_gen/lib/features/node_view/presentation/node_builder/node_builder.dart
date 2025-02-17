import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

import 'functions_subgroup/functions_subgroup.dart';
import 'models_subgroup/models_subgroup.dart';

class NodeBuilder {
  static List<Object> nodeBuilders = [
    // numbersSubGroup(),
    // BlockBuilder().buildBlocks(),
    ModelsSubGroup(),
    FunctionsSubgroup(),
    (Offset offset, VSOutputData? ref) => VSOutputNode(
          type: "Output",
          widgetOffset: offset,
          ref: ref,
        ),
    //
    // (Offset offset, VSOutputData? ref) {
    //   final TextEditingController controller = TextEditingController();
    //   final TextField input = TextField(
    //     controller: controller,
    //     decoration: const InputDecoration(
    //       isDense: true,
    //       contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    //     ),
    //   );
    //
    //   return VSWidgetNode(
    //     type: "ListInput",
    //     widgetOffset: offset,
    //     outputData: [
    //       VSListOutputData(
    //         type: "Output",
    //         outputFunction: (data) => Helper.parseList(controller.text),
    //       ),
    //     ],
    //     child: Expanded(child: input),
    //     setValue: (value) => controller.text = value,
    //     getValue: () => controller.text,
    //   );
    // },
    //
    // (Offset offset, VSOutputData? ref) {
    //   final controller = TextEditingController();
    //   final input = TextField(
    //     controller: controller,
    //     decoration: const InputDecoration(
    //       isDense: true,
    //       contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    //     ),
    //   );
    //
    //   return VSWidgetNode(
    //     type: "Double input",
    //     widgetOffset: offset,
    //     outputData: [
    //       VSDoubleOutputData(
    //         type: "Output",
    //         outputFunction: (data) => double.parse(controller.text),
    //       ),
    //     ],
    //     child: Expanded(child: input),
    //     setValue: (value) => controller.text = value,
    //     getValue: () => controller.text,
    //   );
    // },
    // (Offset offset, VSOutputData? ref) {
    //   final controller = TextEditingController();
    //   final input = TextField(
    //     controller: controller,
    //     decoration: const InputDecoration(
    //       isDense: true,
    //       contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
    //     ),
    //   );
    //
    //   return VSWidgetNode(
    //     type: "int input",
    //     widgetOffset: offset,
    //     outputData: [
    //       VSIntOutputData(
    //         type: "Output",
    //         outputFunction: (data) => int.parse(controller.text),
    //       ),
    //     ],
    //     child: Expanded(child: input),
    //     setValue: (value) => controller.text = value,
    //     getValue: () => controller.text,
    //   );
    // },
    // (Offset offset, VSOutputData<dynamic>? ref) {
    //   Future<Map<String, List<double>>>? splitDataFuture;
    //   TextEditingController controller = TextEditingController();
    //   return VSNodeData(
    //     type: "textField train Test Split",
    //     widgetOffset: offset,
    //     inputData: [
    //       VSListInputData(
    //         type: "data",
    //         initialConnection: ref,
    //       ),
    //       VSDoubleInputData(
    //         type: "test_size",
    //         initialConnection: ref,
    //       ),
    //       VSIntInputData(
    //         interfaceIconBuilder: (context, anchor, data) {
    //           return SizedBox(
    //             width: 20,
    //             height: 20,
    //             child: TextField(controller: controller),
    //           );
    //         },
    //         title: "random",
    //         toolTip: "hello",
    //         type: "random_state",
    //         initialConnection: VSIntOutputData(
    //           type: "int",
    //           outputFunction: (p0) => int.parse(controller.text),
    //         ),
    //       ),
    //     ],
    //     outputData: [
    //       VSListOutputData(
    //         type: "X_train",
    //         outputFunction: (data) async {
    //           print(data);
    //           data["data"] = await data["data"];
    //
    //           splitDataFuture = trainTestSplit(
    //             data["data"],
    //             testSize: data["test_size"] ?? 0.5,
    //             randomState: data["random_state"] ?? 2,
    //           );
    //           Map<String, List<double>> splitData = await splitDataFuture!;
    //
    //           return splitData['X_train']!;
    //         },
    //       ),
    //       VSListOutputData(
    //         type: "X_test",
    //         outputFunction: (data) async {
    //           data["data"] = await data["data"];
    //
    //           splitDataFuture ??= trainTestSplit(data["data"]);
    //
    //           Map<String, List<double>> splitData = await splitDataFuture!;
    //
    //           return splitData['X_test']!;
    //         },
    //       ),
    //     ],
    //   );
    // },
  ];
}
// VSSubgroup(
//   name: "Logic",
//   subgroup: [
//     (Offset offset, VSOutputData? ref) => VSNodeData(
//           type: "Bigger than",
//           widgetOffset: offset,
//           inputData: [
//             VSNumInputData(
//               type: "First",
//               initialConnection: ref,
//             ),
//             VSNumInputData(
//               type: "Second",
//               initialConnection: ref,
//             ),
//           ],
//           outputData: [
//             VSBoolOutputData(
//               type: "Output",
//               outputFunction: (data) => data["First"] > data["Second"],
//             ),
//           ],
//         ),
//     (Offset offset, VSOutputData? ref) => VSNodeData(
//           type: "If",
//           widgetOffset: offset,
//           inputData: [
//             VSBoolInputData(
//               type: "Input",
//               initialConnection: ref,
//             ),
//             VSDynamicInputData(
//               type: "True",
//               initialConnection: ref,
//             ),
//             VSDynamicInputData(
//               type: "False",
//               initialConnection: ref,
//             ),
//           ],
//           outputData: [
//             VSDynamicOutputData(
//               type: "Output",
//               outputFunction: (data) =>
//                   data["Input"] ? data["True"] : data["False"],
//             ),
//           ],
//         ),
//   ],
// ),
// (Offset offset, VSOutputData? ref) {
//   final controller = TextEditingController();
//   final input = TextField(
//     controller: controller,
//     decoration: const InputDecoration(
//       isDense: true,
//       contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//     ),
//   );
//
//   return VSWidgetNode(
//     type: "Input",
//     widgetOffset: offset,
//     outputData: VSStringOutputData(
//       type: "Output",
//       outputFunction: (data) => controller.text,
//     ),
//     child: Expanded(child: input),
//     setValue: (value) => controller.text = value,
//     getValue: () => controller.text,
//   );
// },
// (Offset offset, VSOutputData<dynamic>? ref) {
//   Future<Map<String, List<double>>>? splitDataFuture;
//   return VSNodeData(
//     type: "train Test Split",
//     widgetOffset: offset,
//     inputData: [
//       VSListInputData(
//         type: "data",
//         initialConnection: ref,
//       ),
//       VSDoubleInputData(
//         type: "test_size",
//         initialConnection: ref,
//       ),
//       VSIntInputData(
//         type: "random_state",
//         initialConnection: ref,
//       ),
//     ],
//     outputData: [
//       VSListOutputData(
//         type: "X_train",
//         outputFunction: (data) async {
//           data["data"] = await data["data"];
//
//           splitDataFuture = trainTestSplit(
//             data["data"],
//             testSize: data["test_size"] ?? 0.5,
//             randomState: data["random_state"] ?? 2,
//           );
//           Map<String, List<double>> splitData = await splitDataFuture!;
//
//           return splitData['X_train']!;
//         },
//       ),
//       VSListOutputData(
//         type: "X_test",
//         outputFunction: (data) async {
//           data["data"] = await data["data"];
//
//           splitDataFuture ??= trainTestSplit(data["data"]);
//
//           Map<String, List<double>> splitData = await splitDataFuture!;
//
//           return splitData['X_test']!;
//         },
//       ),
//     ],
//   );
// },
