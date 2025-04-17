import os, sys, json
import warnings

# Suppress TensorFlow warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

# Suppress TensorFlow deprecation warnings
import tensorflow as tf
tf.get_logger().setLevel('ERROR')

# getting the API key from a JSON file
api_key_path = os.path.join(os.path.dirname(__file__), 'credentials', 'google_credentials.json')
if not os.path.exists(api_key_path):
    raise FileNotFoundError(f"API key file not found at {api_key_path}. Please provide the correct path.")
with open(api_key_path, 'r') as f:
    api_key = json.load(f)

# setting the API key as an environment variable
os.environ['GOOGLE_API_KEY'] = api_key.get("GOOGLE_API_KEY")

warnings.filterwarnings('ignore', category=DeprecationWarning)

# append cli to sys.path to import it.
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
