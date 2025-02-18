ds_name = {}

def set_ds_name(name, ds_id):
    global ds_name
    ds_name[ds_id] = name

def get_ds_name(ds_id):
    global ds_name
    if not ds_name.get(ds_id):
        return None
    return ds_name[ds_id]

def clear_ds_name(ds_id):
    global ds_name
    if not ds_name.get(ds_id):
        return None
    del ds_name[ds_id]
