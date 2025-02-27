
import os
from cmd_handler import cmd_handler
from save_load import load_data_from_file, save_data_to_file

def main(cmds):
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data_store.json')
    load_data_from_file(path)
    for cmd in cmds:
        result = cmd_handler(cmd)
        if result:
            print(result)
    save_data_to_file(path)


commands = ['aino selusr admin admin',
            'aino mkprj prj1',
            'aino mkwf logreg_workflow',
            "aino mkblk load_iris ([],['port1']) ([])",
            "aino mkblk train_test_split1 (['port1'],['port2','port3']) (['test_size',0.2],['random_state',42],['features_name','data'])",
            "aino mkblk train_test_split2 (['port1'],['port4','port5']) (['test_size',0.2],['random_state',42],['features_name','target'])",
            "aino mkblk standard_scaler ([],['port6']) ([])",
            "aino mkblk fit_transform (['port6','port2'],['port7']) ([])",
            "aino mkblk transform (['port3'],['port8']) ([])",
            "aino mkblk logestic_regression ([],['port9']) ([])",
            "aino mkblk fit (['port9','port7','port4'],['port10']) ([])",
            "aino mkblk predict (['port10','port8'],['port11']) ([])",
            "aino mkblk accurac_score (['port11','port5'],[]) ([])"]

if __name__ == "__main__":
    print(main(commands))


