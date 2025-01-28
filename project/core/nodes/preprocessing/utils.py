



class PreprocessorAttributeExtractor:
    """Extracts attributes from a preprocessors."""
    @staticmethod
    def get_attributes(preprocessor):

        excluded_attributes = {
            "n_samples_seen_",
            "n_features_in_",
            "feature_names_in_",
            "dtype_",
            "sparse_input_"
        }
        
        attributes = {}
        for attr in dir(preprocessor):
            if attr.endswith("_") and not attr.startswith("_") and attr not in excluded_attributes:
                atr = getattr(preprocessor, attr)
                if hasattr(atr, "tolist"):
                    attributes[attr] = atr.tolist()
        return attributes
