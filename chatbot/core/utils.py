# import json
# import spacy
# from sentence_transformers import SentenceTransformer, util
# from fuzzywuzzy import fuzz

# nlp = spacy.load("en_core_web_sm")
# name_extractor = SentenceTransformer('all-MiniLM-L6-v2')


def extract_id_message(json_str):
    try:
        json_obj = eval(json_str)
        message = json_obj.get("message")
        node_id = json_obj.get("node_id")
        json_obj = {"message": message, "node_id": node_id}
        return f'{json_obj}'
    except:
        return json_str



# def extract_keywords_hybrid(user_input: str, reference_keywords, top_n, transformer_thresh=0.7, fuzzy_thresh=80):
#     keyword_embeddings = name_extractor.encode(reference_keywords, convert_to_tensor=True)
#     doc = nlp(user_input.lower())
#     phrases = [chunk.text for chunk in doc.noun_chunks]
#     matched_keywords = []

#     for phrase in phrases:
#         phrase_embedding = name_extractor.encode(phrase, convert_to_tensor=True)
#         cosine_scores = util.cos_sim(phrase_embedding, keyword_embeddings)[0]

#         for idx, score in enumerate(cosine_scores):
#             if score >= transformer_thresh:
#                 if reference_keywords[idx] not in matched_keywords:
#                     matched_keywords.append(reference_keywords[idx])

#         # === Fuzzy matching fallback ===
#         for keyword in reference_keywords:
#             if fuzz.ratio(phrase, keyword.replace("_", " ")) >= fuzzy_thresh:
#                 if keyword not in matched_keywords:
#                     matched_keywords.append(keyword)
#     top_n = min(top_n, len(matched_keywords))
#     best_match = matched_keywords.copy()
#     if len(matched_keywords) > top_n:
#         best_match = sorted(matched_keywords, key=lambda x: fuzz.ratio(user_input, x), reverse=True)[:top_n]
#     matched_keywords = list(filter(lambda x: x in best_match, matched_keywords))
#     return matched_keywords


# def args_extractor(names, reference_keywords, data_mapping):
#     result = []
#     for name in names:
#         if name in reference_keywords and name in data_mapping:
#             # node_type = mapping[name]
#             args_str = json.dumps(data_mapping[name], separators=(',', ':'))
#             result.append(args_str)
#     return result

# def replace_args(commands, replacements, names, reference_keywords):

#     c = 0
#     for i, command in enumerate(commands):
#         if "<args>" in command:
#             if names[c] in reference_keywords:
#                 commands[i] = command.replace("<args>", replacements[c])
#                 c += 1

#     return commands


