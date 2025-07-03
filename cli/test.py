import unittest
import os
import json
from handlers.user_handler import reg_usr, log_usr, rm_usr, mk_adm, is_sudo, get_recent
from save_load import save_data, load_data, load_backup_data

TEST_DATA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'test_data.json')

def mock_save_data(data):
    with open(TEST_DATA_PATH, "w") as f:
        json.dump(data, f)

def mock_load_data():
    if os.path.exists(TEST_DATA_PATH):
        with open(TEST_DATA_PATH, "r") as f:
            return json.load(f)
    return {"users": {}, "admin": [], "active_user": None, "active_project": None}

def mock_load_backup_data():
    return {"users": {}, "admin": [], "active_user": None, "active_project": None}

class TestUserManagement(unittest.TestCase):
    def setUp(self):
        self.original_save = save_data
        self.original_load = load_data
        self.original_backup = load_backup_data

        # Replace with mock functions
        import save_load
        save_load.save_data = mock_save_data
        save_load.load_data = mock_load_data
        save_load.load_backup_data = mock_load_backup_data

        # Reset test data
        mock_save_data({"users": {}, "admin": [], "active_user": None, "active_project": None})

    def tearDown(self):
        # Restore original functions
        import save_load
        save_load.save_data = self.original_save
        save_load.load_data = self.original_load
        save_load.load_backup_data = self.original_backup

        if os.path.exists(TEST_DATA_PATH):
            os.remove(TEST_DATA_PATH)

    def test_register_user(self):
        success, msg = reg_usr("testuser", "123")
        self.assertTrue(success)
        self.assertIn("created", msg)

    def test_login_user(self):
        reg_usr("testuser", "123")
        success, msg = log_usr("testuser", "123")
        self.assertTrue(success)
        self.assertIn("selected", msg)

    def test_duplicate_registration(self):
        reg_usr("testuser", "123")
        success, msg = reg_usr("testuser", "123")
        self.assertFalse(success)
        self.assertIn("already exists", msg)

    def test_make_admin(self):
        reg_usr("admin", "123")
        reg_usr("other", "456")
        # Make "admin" active
        log_usr("admin", "123")
        mk_adm("admin")  # Ensure admin is admin
        success, msg = mk_adm("other")
        print(msg)
        self.assertTrue(success)
        self.assertIn("is now an admin", msg)

    def test_remove_user(self):
        reg_usr("admin", "123")
        reg_usr("user2", "456")
        log_usr("admin", "123")
        mk_adm("admin")
        success, msg = rm_usr("user2")
        self.assertTrue(success)
        self.assertIn("removed", msg)

    def test_is_sudo(self):
        reg_usr("admin", "123")
        log_usr("admin", "123")
        mk_adm("admin")
        self.assertTrue(is_sudo())

if __name__ == "__main__":
    unittest.main()
