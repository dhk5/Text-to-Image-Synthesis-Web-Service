#!/usr/local/bin/python3

import os
from nltk.corpus import wordnet


def get_word_net_ids(nouns):
    '''
    Get the wordnet id of a synonym of each noun for which bounding box is available.

    :param nouns:
    :return:
    '''
    file_path = os.path.dirname(os.path.realpath(__file__))
    image_bbox_file_path = os.path.join(str(file_path), 'imagenet.bbox.obtain_synset_list.txt')
    search_file_object = open(image_bbox_file_path, 'r', encoding='utf8')
    search_file_text = search_file_object.read().rstrip().splitlines()

    # The dictionary object containing nouns
    # as keys and the corresponding wordnet ids as values
    word_net_id_dict = {}
    for noun in nouns:

        # Get synonyms
        syn_sets = wordnet.synsets(noun, wordnet.NOUN)
        word_net_id = ''
        for syn_set in syn_sets:

            # Get wordnet id of a synonym
            word_net_id = syn_set.pos() + str(syn_set.offset()).zfill(8)

            # Stop if the bounding box is available for found wordnet id
            if word_net_id in search_file_text:
                break

        word_net_id_dict[noun] = word_net_id

    return word_net_id_dict
