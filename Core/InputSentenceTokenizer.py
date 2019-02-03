#!/usr/local/bin/python3

# import nltk
# nltk.download('punkt')
# nltk.download('stopwords')
# nltk.download('averaged_perceptron_tagger')

from nltk import pos_tag
from nltk import sent_tokenize
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from inflection import singularize

import string

prepositions_list = {'before', 'after', 'above', 'below', 'to',
                     'on', 'off', 'over', 'under', 'further',
                     'from', 'up', 'down', 'in', 'out', 'between'}

def pre_process_sentence(input_sentence):
    """
    Pre-process the input_sentence parameter to singularize words and
    remove stop words and punctuations.

    :param input_sentence: string
    :return:
    """
    # Split the input into sentences and select the first sentence
    sentences = sent_tokenize(input_sentence)
    sentence = sentences[0]

    # Split the sentence into words
    words = word_tokenize(sentence)

    # Convert to lower case
    words_lower = [word.lower() for word in words]

    # Remove punctuation from each word
    table = str.maketrans('', '', string.punctuation)
    words_no_punct = [word.translate(table) for word in words_lower]

    # Remove remaining tokens that are not alphabetic
    words_alpha = [word for word in words_no_punct if word.isalpha()]

    # Filter out stop words except prepositions.
    stop_words = set(stopwords.words('english'))
    stop_words = [word for word in stop_words if word not in prepositions_list]
    words_prepositions = [word for word in words_alpha if word not in stop_words]

    # Stemming
    words_stemed = [singularize(word) for word in words_prepositions if word]
    return words_stemed


def tag_words(words):
    """
    Create a dictionary with 'Dependent_Noun', 'Main_Noun',
    and 'Preposition' as keys and words as values.

    :param words: list of pre-process words
    :return: dictionary
    """
    word_dict = {}
    noun_list = []
    tag_list = []

    # Differentiate between nouns and preposition
    words = pos_tag(words)
    for word, tag in words:
        if tag.startswith('N'):
            noun_list.append(word)
        if tag.startswith('IN'):
            tag_list.append(word)

    word_dict['Dependent_Noun'] = noun_list[0]
    word_dict['Main_Noun'] = noun_list[1]
    word_dict['Preposition'] = tag_list[0]
    return word_dict


def tokenize(sentence):
    """
    Tokenize the sentence parameter to
    'Dependent_Noun', 'Main_Noun', and 'Preposition'.

    :param sentence: string
    :return: dictionary
    """
    words = pre_process_sentence(sentence)
    word_dict = tag_words(words)
    # for key, val in word_dict.items():
    #     print(key + ": " + val)
    return word_dict
