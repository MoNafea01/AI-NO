import 'vs_node_data_provider.dart';

class VSHistoryManger {
  ///A List of the last states [nodeManager.nodes] has had
  ///
  ///Gets updated whenever [nodeManager]s nodes get set
  final List<String> _history = [];
  late VSNodeDataProvider provider;

  void updateHistory() {
    if (historyIndex < (_history.length - 1)) {
      _history.removeRange(historyIndex + 1, _history.length);
    }

    _history.add(provider.nodeManager.serializeNodes());
    historyIndex++;
  }

  ///Loads the state of [_history] at the current [historyIndex]
  void loadHistory() {
    provider.loadSerializedNodes(_history[historyIndex]);
  }

  ///The current index of the history
  int get historyIndex => _historyIndex;
  int _historyIndex = 0;
  set historyIndex(int value) {
    if (value < 0) {
      value = 0;
    }
    if (_history.elementAtOrNull(value) != null) {
      _historyIndex = value;
    }
  }

  ///Will overwrite the current nodes with the last state according to [_history]
  ///
  ///Returns true when the state has successfull been undone
  bool undo() {
    final willUndo = _history.isNotEmpty;
    if (willUndo) {
      historyIndex--;
      loadHistory();
    }
    return willUndo;
  }

  ///Will overwrite the current nodes with the next state according to [_future]
  ///
  ///Returns true when the state has successfull been redone
  bool redo() {
    final willRedo = (historyIndex - 1) < _history.length;
    if (willRedo) {
      historyIndex++;
      loadHistory();
    }
    return willRedo;
  }
}
