import 'package:ai_gen/core/classes/model_class.dart';
import 'package:ai_gen/features/node_view/data/functions/create_model.dart';
import 'package:ai_gen/node_package/custom_widgets/vs_text_input_data.dart';
import 'package:ai_gen/node_package/data/standard_interfaces/vs_model_interface.dart';
import 'package:ai_gen/node_package/vs_node_view.dart';
import 'package:flutter/material.dart';

class ModelsSubGroup extends VSSubgroup {
  ModelsSubGroup()
      : super(
          name: 'Models',
          subgroup: [
            linearModelsSubGroup(),
            svmSubGroup(),
            nativeBayesSubGroup(),
            knnSubGroup(),
          ],
        );

  static VSSubgroup knnSubGroup() {
    return VSSubgroup(name: "Knn", subgroup: [
      VSSubgroup(name: "regression", subgroup: [
        (Offset offset, VSOutputData? ref) {
          // ignore: non_constant_identifier_names
          final TextEditingController Knnrcontroller = TextEditingController()
            ..text = "5";
          return VSNodeData(
            type: "knnr",
            widgetOffset: offset,
            inputData: [
              VsTextInputData(type: "Parameter", controller: Knnrcontroller)
            ],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "knn",
                    "model_type": "knnr",
                    "task": "regression",
                    "params": {"n_neighbors": int.parse(Knnrcontroller.text)},
                  },
                ),
              ),
            ],
          );
        },
      ]),
      VSSubgroup(name: "classification", subgroup: [
        (Offset offset, VSOutputData? ref) {
          // ignore: non_constant_identifier_names
          final TextEditingController Knnccontroller = TextEditingController()
            ..text = "5";
          return VSNodeData(
            type: "knnc",
            widgetOffset: offset,
            inputData: [
              VsTextInputData(type: "Parameter", controller: Knnccontroller)
            ],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "gaussian_nb",
                    "model_type": "naive_bayes",
                    "task": "classification",
                    "params": {"n_neighbors": int.parse(Knnccontroller.text)},
                  },
                ),
              ),
            ],
          );
        },
      ]),
    ]);
  }

  static VSSubgroup nativeBayesSubGroup() {
    return VSSubgroup(name: "naive_bayes", subgroup: [
      VSSubgroup(name: "classification", subgroup: [
        (Offset offset, VSOutputData? ref) {
          return VSNodeData(
            type: "gaussian_nb",
            widgetOffset: offset,
            inputData: [],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "gaussian_nb",
                    "model_type": "naive_bayes",
                    "task": "classification",
                    "params": {},
                  },
                ),
              ),
            ],
          );
        },
        (Offset offset, VSOutputData? ref) {
          return VSNodeData(
            type: "multinomial_nb",
            widgetOffset: offset,
            inputData: [],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "gaussian_nb",
                    "model_type": "naive_bayes",
                    "task": "classification",
                    "params": {},
                  },
                ),
              ),
            ],
          );
        },
        (Offset offset, VSOutputData? ref) {
          return VSNodeData(
            type: "bernoulli_nb",
            widgetOffset: offset,
            inputData: [],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "gaussian_nb",
                    "model_type": "naive_bayes",
                    "task": "classification",
                    "params": {},
                  },
                ),
              ),
            ],
          );
        },
      ]),
    ]);
  }

  static VSSubgroup svmSubGroup() {
    return VSSubgroup(name: "svm", subgroup: [
      VSSubgroup(name: "regression", subgroup: []),
      VSSubgroup(name: "classification", subgroup: [
        (Offset offset, VSOutputData? ref) {
          final TextEditingController rbfSvccontroller = TextEditingController()
            ..text = "1.0";
          return VSNodeData(
            type: "rbf_svc",
            widgetOffset: offset,
            inputData: [
              VsTextInputData(type: "Parameter", controller: rbfSvccontroller),
            ],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "svm",
                    "model_type": "rbf_svc",
                    "task": "classification",
                    "params": {"C": double.parse(rbfSvccontroller.text)},
                  },
                ),
              ),
            ],
          );
        },
        (Offset offset, VSOutputData? ref) {
          final TextEditingController polySvccontroller =
              TextEditingController()..text = "1.0";
          return VSNodeData(
            type: "poly_svc",
            widgetOffset: offset,
            inputData: [
              VsTextInputData(type: "Parameter", controller: polySvccontroller),
            ],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "svm",
                    "model_type": "rbf_svc",
                    "task": "classification",
                    "params": {"C": double.parse(polySvccontroller.text)},
                  },
                ),
              ),
            ],
          );
        },
        (Offset offset, VSOutputData? ref) {
          final TextEditingController sigmoidSvccontroller =
              TextEditingController()..text = "1.0";
          return VSNodeData(
            type: "sigmoid_svc",
            widgetOffset: offset,
            inputData: [
              VsTextInputData(
                  type: "Parameter", controller: sigmoidSvccontroller),
            ],
            outputData: [
              VSModelOutputData(
                type: "Output",
                outputFunction: (data) => apiCall(
                  {
                    "model_name": "svm",
                    "model_type": "rbf_svc",
                    "task": "classification",
                    "params": {"C": double.parse(sigmoidSvccontroller.text)},
                  },
                ),
              ),
            ],
          );
        },
      ]),
    ]);
  }

  static VSSubgroup linearModelsSubGroup() {
    return VSSubgroup(
      name: "linear_models",
      subgroup: [
        VSSubgroup(
          name: "regression",
          subgroup: [
            (Offset offset, VSOutputData? ref) {
              return VSNodeData(
                type: "linear_regression",
                widgetOffset: offset,
                inputData: [],
                outputData: [
                  VSModelOutputData(
                    type: "Output",
                    outputFunction: (data) => apiCall(
                      AIModel(
                        modelName: "linear_regression",
                        modelType: "linear_models",
                        task: "regression",
                      ).createModelToJson(),
                    ),
                  ),
                ],
              );
            },
            (Offset offset, VSOutputData? ref) {
              final TextEditingController ridgeController =
                  TextEditingController()..text = "1.0";
              return VSNodeData(
                type: "ridge",
                widgetOffset: offset,
                inputData: [
                  VsTextInputData(
                      type: "Parameter", controller: ridgeController)
                ],
                outputData: [
                  VSModelOutputData(
                    type: "Output",
                    outputFunction: (data) => apiCall(
                      AIModel(
                        modelName: "ridge",
                        modelType: "linear_models",
                        task: "regression",
                        params: {"alpha": double.parse(ridgeController.text)},
                      ).createModelToJson(),
                    ),
                  ),
                ],
              );
            },
            (Offset offset, VSOutputData? ref) {
              final TextEditingController lassoController =
                  TextEditingController()..text = "1.0";
              return VSNodeData(
                type: "lasso",
                widgetOffset: offset,
                inputData: [
                  VsTextInputData(
                      type: "Parameter", controller: lassoController)
                ],
                outputData: [
                  VSModelOutputData(
                    type: "Output",
                    outputFunction: (data) => apiCall(
                      {
                        "model_name": "lasso",
                        "model_type": "linear_models",
                        "task": "regression",
                        "params": {"alpha": double.parse(lassoController.text)},
                      },
                    ),
                  ),
                ],
              );
            },
            (Offset offset, VSOutputData? ref) {
              final TextEditingController sgdRegressioncontroller =
                  TextEditingController()..text = "l2";
              return VSNodeData(
                type: "sgd_regression",
                widgetOffset: offset,
                inputData: [
                  VsTextInputData(
                      type: "Parameter", controller: sgdRegressioncontroller)
                ],
                outputData: [
                  VSModelOutputData(
                    type: "Output",
                    outputFunction: (data) => apiCall(
                      {
                        "model_name": "sgd_regression",
                        "model_type": "linear_models",
                        "task": "regression",
                        "params": {"penalty": sgdRegressioncontroller.text},
                      },
                    ),
                  ),
                ],
              );
            },
          ],
        ),
        VSSubgroup(name: "classification", subgroup: [
          (Offset offset, VSOutputData? ref) {
            // ignore: non_constant_identifier_names
            // final TextEditingController Ccontroller =
            //     TextEditingController()..text = "1.0";

            // ignore: non_constant_identifier_names
            final TextEditingController Penaltycontroller =
                TextEditingController()..text = "l2";

            return VSNodeData(
              type: "logistic_regression",
              widgetOffset: offset,
              inputData: [
                // VsTextInputData(

                //     type: "Parameter", controller: Ccontroller),

                VsTextInputData(
                    type: "Parameter", controller: Penaltycontroller),
              ],
              outputData: [
                VSModelOutputData(
                  type: "Output",
                  outputFunction: (data) => apiCall(
                    {
                      "model_name": "logistic_regression",
                      "model_type": "linear_models",
                      "task": "classification",
                      "params": {
                        //"C": double.parse(Ccontroller.text),

                        "penalty": Penaltycontroller.text
                      },
                    },
                  ),
                ),
              ],
            );
          },
          (Offset offset, VSOutputData? ref) {
            final TextEditingController ridgeClassifiercontroller =
                TextEditingController()..text = "1.0";
            return VSNodeData(
              type: "ridge_classifier",
              widgetOffset: offset,
              inputData: [
                VsTextInputData(
                    type: "Parameter", controller: ridgeClassifiercontroller),
              ],
              outputData: [
                VSModelOutputData(
                  type: "Output",
                  outputFunction: (data) => apiCall(
                    {
                      "model_name": "LinearRegression",
                      "model_type": "linear_models",
                      "task": "classification",
                      "params": {
                        "alpha": double.parse(ridgeClassifiercontroller.text)
                      },
                    },
                  ),
                ),
              ],
            );
          },
          (Offset offset, VSOutputData? ref) {
            final TextEditingController sgdClassifiercontroller =
                TextEditingController()..text = "l2";
            return VSNodeData(
              type: "sgd_classifier",
              widgetOffset: offset,
              inputData: [
                VsTextInputData(
                    type: "Parameter", controller: sgdClassifiercontroller),
              ],
              outputData: [
                VSModelOutputData(
                  type: "Output",
                  outputFunction: (data) => apiCall(
                    {
                      "model_name": "LinearRegression",
                      "model_type": "linear_models",
                      "task": "classification",
                      "params": {"penalty": sgdClassifiercontroller.text},
                    },
                  ),
                ),
              ],
            );
          },
        ]),
      ],
    );
  }

  static VSSubgroup numbersSubGroup() {
    return VSSubgroup(
      name: "Numbers",
      subgroup: [
        (Offset offset, VSOutputData? ref) => VSNodeData(
              type: "Parse int",
              widgetOffset: offset,
              inputData: [
                VSStringInputData(
                  type: "Input",
                  initialConnection: ref,
                ),
              ],
              outputData: [
                VSIntOutputData(
                  type: "Output",
                  outputFunction: (data) => int.parse(data["Input"]),
                ),
              ],
            ),
        (Offset offset, VSOutputData? ref) => VSNodeData(
              type: "Sum",
              widgetOffset: offset,
              inputData: [
                VSNumInputData(
                  type: "Input 1",
                  initialConnection: ref,
                ),
                VSNumInputData(
                  type: "Input 2",
                  initialConnection: ref,
                )
              ],
              outputData: [
                VSNumOutputData(
                  type: "output",
                  outputFunction: (data) {
                    return (data["Input 1"] ?? 0) + (data["Input 2"] ?? 0);
                  },
                ),
              ],
            ),
      ],
    );
  }
}
