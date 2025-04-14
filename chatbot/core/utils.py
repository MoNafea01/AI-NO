import json, ast, re
import spacy
from sentence_transformers import SentenceTransformer, util
from fuzzywuzzy import fuzz

nlp = spacy.load("en_core_web_sm")
name_extractor = SentenceTransformer('all-MiniLM-L6-v2')

def extract_keywords_hybrid(user_input: str, reference_keywords, transformer_thresh=0.7, fuzzy_thresh=80):
    keyword_embeddings = name_extractor.encode(reference_keywords, convert_to_tensor=True)
    doc = nlp(user_input.lower())
    phrases = [chunk.text for chunk in doc.noun_chunks]
    matched_keywords = []

    for phrase in phrases:
        phrase_embedding = name_extractor.encode(phrase, convert_to_tensor=True)
        cosine_scores = util.cos_sim(phrase_embedding, keyword_embeddings)[0]

        for idx, score in enumerate(cosine_scores):
            if score >= transformer_thresh:
                if reference_keywords[idx] not in matched_keywords:
                    matched_keywords.append(reference_keywords[idx])

        # === Fuzzy matching fallback ===
        for keyword in reference_keywords:
            if fuzz.ratio(phrase, keyword.replace("_", " ")) >= fuzzy_thresh:
                if keyword not in matched_keywords:
                    matched_keywords.append(keyword)

    return matched_keywords

def parse_command_list(output: str):
    pattern = r"\[(.*?)\]"
    matches = re.findall(pattern, output, re.DOTALL)
    if matches:
        output = f"[{matches[0]}]"
    try:
        command_list = ast.literal_eval(output.strip())
        return command_list if isinstance(command_list, list) else [command_list]
    except Exception as e:
        return [f"Failed to parse list: {e}"]

def args_extractor(names, mapping, data_mapping):
    result = []
    for name in names:
        if name in mapping and name in data_mapping:
            node_type = mapping[name]
            args_str = json.dumps(data_mapping[name], separators=(',', ':'))
            result.append((node_type, args_str))
    return result

def replace_args(commands, replacements):
    for i in range(min(len(commands), len(replacements))):
        commands[i] = commands[i].replace("<node_name>", replacements[i][0]).replace("<args>", replacements[i][1])
    return commands
