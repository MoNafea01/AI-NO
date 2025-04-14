import json, ast, re
import spacy
from sentence_transformers import SentenceTransformer, util
from fuzzywuzzy import fuzz

nlp = spacy.load("en_core_web_sm")
name_extractor = SentenceTransformer('all-MiniLM-L6-v2')

def extract_keywords_hybrid(user_input: str, reference_keywords, top_n, transformer_thresh=0.7, fuzzy_thresh=80):
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
    top_n = min(top_n, len(matched_keywords))
    best_match = matched_keywords.copy()
    if len(matched_keywords) > top_n:
        best_match = sorted(matched_keywords, key=lambda x: fuzz.ratio(user_input, x), reverse=True)[:top_n]
    matched_keywords = list(filter(lambda x: x in best_match, matched_keywords))
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
            # node_type = mapping[name]
            args_str = json.dumps(data_mapping[name], separators=(',', ':'))
            result.append(args_str)
    return result

def replace_args(commands:list[str], args, names, mapper):
    c = 0
    for i, command in enumerate(commands):
        if "<args>" in command:
            print(names)
            print(args)
            print(command)
            if names[c] in list(mapper.keys()):
                commands[i] = command.replace("<args>", args[c])
                c += 1
            else:
                continue
        else:
            continue

    return commands
