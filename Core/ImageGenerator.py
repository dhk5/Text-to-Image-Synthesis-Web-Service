#!/usr/local/bin/python3

import InputSentenceTokenizer
import WordNetIdGetter
import ImageFetcher
import ImageProcessor

import random
import sys
import os


def main(args):
    '''
    The main function that takes input sentence as parameter and
    visualize the scene based on the input.

    :param args:
    :return:
    '''
    # Tokenize the input sentence to Main_Noun, Dependent_Noun, and Preposition
    word_dict = InputSentenceTokenizer.tokenize(args[1])
    failed = "FAILED"

    # Create a dictionary with wordnet id for noun objects
    nouns = {word_dict.get('Dependent_Noun'), word_dict.get('Main_Noun')}
    word_net_id_dict = WordNetIdGetter.get_word_net_ids(nouns)
    for key, value in word_net_id_dict.items():
        if not value:
            print(failed)
            return failed

    # Fetch images of the noun objects
    ImageFetcher.fetchImages(word_net_id_dict)

    # Randomly pick images to generate an image that describes the input sentence
    image_path_list_to_process = []
    for key, value in word_net_id_dict.items():
        image_path = getRandomImagePath(value)
        image_path_list_to_process.append(image_path)

    # Generate the image
    processed_image_path_list = ImageProcessor.process_images(image_path_list_to_process)
    created_image_path = ImageProcessor.generateImage(processed_image_path_list, word_dict.get('Preposition'))
    if created_image_path:
        print(created_image_path)
        return created_image_path
    else:
        print(failed)
        return failed


def getRandomImagePath(word_net_id):
    '''
    Returns a random image path, chosen among the files of the given image id.

    :param word_net_id: WordNet id of target image
    :return: image path
    '''
    image_dir = os.path.join(os.getcwd(), 'Images')
    sub_dir = os.path.join(image_dir, word_net_id)
    files = os.listdir(sub_dir)
    index = random.randrange(1, len(files))
    return os.path.join(sub_dir, files[index])


if __name__ == '__main__':
    main(sys.argv)
